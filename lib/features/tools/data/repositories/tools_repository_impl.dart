import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../../domain/entities/ping_result.dart';
import '../../domain/entities/traceroute_hop.dart';
import '../../domain/repositories/tools_repository.dart';
import '../../../../core/network/routeros_client_v2.dart';
import '../../../../core/network/routeros_client.dart';
import '../models/dns_lookup_result_model.dart';
import '../models/ping_result_model.dart';
import '../models/traceroute_hop_model.dart';

/// Implementation of ToolsRepository
/// Uses RouterOSClientV2 for non-streaming operations (better API)
/// Uses legacy RouterOSClient for streaming (package has bugs with streaming)
class ToolsRepositoryImpl implements ToolsRepository {
  final RouterOSClientV2 routerOsClient;
  final RouterOSClient legacyClient;

  ToolsRepositoryImpl({
    required this.routerOsClient,
    required this.legacyClient,
  });

  @override
  Future<Either<Failure, PingResult>> ping({
    required String target,
    int count = 4,
    int timeout = 1000,
  }) async {
    try {
      final response = await routerOsClient.ping(
        address: target,
        count: count,
      );

      final model = PingResultModel.fromRouterOS(target, response);
      return Right(model.toEntity());
    } on ServerException {
      return Left(const ServerFailure('Failed to ping target'));
    }
  }

  @override
  Future<Either<Failure, void>> stopPing() async {
    try {
      // Stop ping stream using legacy client
      await legacyClient.stopStreaming();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to stop ping: $e'));
    }
  }

  @override
  Stream<PingResult> pingStream({
    required String target,
    int interval = 1,
    int count = 100,
    int? size,
    int? ttl,
    String? srcAddress,
    String? interfaceName,
    bool doNotFragment = false,
  }) async* {
    AppLogger.i('pingStream started for target: $target', tag: 'ToolsRepositoryImpl');
    try {
      int packetsSent = 0;
      int packetsReceived = 0;
      Duration minRtt = Duration.zero;
      Duration avgRtt = Duration.zero;
      Duration maxRtt = Duration.zero;
      final packets = <PingPacket>[];
      
      AppLogger.i('Getting stream from legacyClient...', tag: 'ToolsRepositoryImpl');
      // Use legacy client for streaming (package has bugs)
      final stream = legacyClient.pingStream(
        address: target,
        count: count,
        interval: interval,
        size: size,
        ttl: ttl,
        srcAddress: srcAddress,
        interfaceName: interfaceName,
        doNotFragment: doNotFragment,
      );
      AppLogger.i('Got stream, starting listen...', tag: 'ToolsRepositoryImpl');
      
      AppLogger.i('Starting await for loop on stream...', tag: 'ToolsRepositoryImpl');
      int dataCount = 0;
      await for (final data in stream) {
        dataCount++;
        AppLogger.i('Received ping data #$dataCount: $data', tag: 'ToolsRepositoryImpl');
        // Update statistics from each packet
        if (data.containsKey('sent')) {
          packetsSent = int.tryParse(data['sent'] ?? '0') ?? 0;
        }
        if (data.containsKey('received')) {
          packetsReceived = int.tryParse(data['received'] ?? '0') ?? 0;
        }
        if (data.containsKey('min-rtt') && data['min-rtt'] != null) {
          minRtt = PingResultModel.parseDuration(data['min-rtt']!);
        }
        if (data.containsKey('avg-rtt') && data['avg-rtt'] != null) {
          avgRtt = PingResultModel.parseDuration(data['avg-rtt']!);
        }
        if (data.containsKey('max-rtt') && data['max-rtt'] != null) {
          maxRtt = PingResultModel.parseDuration(data['max-rtt']!);
        }

        // Add packet to list
        final seq = int.tryParse(data['seq'] ?? '');
        if (seq != null) {
          final rtt = data['time'] != null ? PingResultModel.parseDuration(data['time']!) : null;
          final received = rtt != null;
          final error = received ? null : 'timeout';

          packets.add(PingPacket(
            sequence: seq,
            rtt: rtt,
            received: received,
            error: error,
          ));
        }

        final packetLossPercent = packetsSent > 0
            ? ((packetsSent - packetsReceived) / packetsSent * 100).round()
            : 0;

        // Yield updated result
        yield PingResult(
          target: target,
          packetsSent: packetsSent,
          packetsReceived: packetsReceived,
          packetLossPercent: packetLossPercent,
          minRtt: minRtt,
          avgRtt: avgRtt,
          maxRtt: maxRtt,
          isRunning: true,
          packets: List.from(packets),
        );
      }
    } catch (e) {
      throw ServerException('Failed to perform streaming ping: $e');
    }
  }

  @override
  Future<Either<Failure, List<TracerouteHop>>> traceroute({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  }) async {
    try {
      final response = await routerOsClient.traceroute(
        address: target,
        maxHops: maxHops,
        timeout: timeout,
      );

      // RouterOS sends real-time updates for each probe
      // We need to keep only the LAST update for each unique hop (address)
      // Group by address and keep the one with highest 'sent' count
      final hopMap = <String, Map<String, String>>{};
      var hopIndex = 0;
      
      for (final data in response) {
        // Skip done messages
        if (data['type'] == 'done') continue;
        
        // Create unique key: address or index for empty addresses
        final address = data['address'] ?? '';
        final key = address.isNotEmpty ? address : 'hop_$hopIndex';
        
        // Keep this update if it's new or has higher 'sent' count
        final currentSent = int.tryParse(data['sent'] ?? '0') ?? 0;
        final existingSent = int.tryParse(hopMap[key]?['sent'] ?? '0') ?? 0;
        
        if (!hopMap.containsKey(key) || currentSent > existingSent) {
          hopMap[key] = data;
          if (address.isEmpty) hopIndex++;
        }
      }
      
      // Convert to hops list in order
      final hops = hopMap.values
          .toList()
          .asMap()
          .entries
          .map((e) => TracerouteHopModel.fromRouterOS(e.value, e.key).toEntity())
          .toList();

      return Right(hops);
    } on ServerException {
      return Left(const ServerFailure('Failed to perform traceroute'));
    }
  }

  @override
  Stream<TracerouteHop> tracerouteStream({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  }) async* {
    try {
      // Map to track hops by their hop number
      final hopMap = <int, TracerouteHop>{};
      
      // Track current section and hop index within section
      int currentSection = -1;
      int hopIndex = 0;
      
      // Use legacy client for streaming
      final stream = legacyClient.tracerouteStream(
        address: target,
        maxHops: maxHops,
      );
      
      await for (final data in stream) {
        // Skip done/trap messages
        if (data['type'] == 'done' || data['type'] == 'trap') continue;
        
        // Get section number
        final section = int.tryParse(data['.section'] ?? '') ?? 0;
        
        // When section changes, reset hop index
        if (section != currentSection) {
          currentSection = section;
          hopIndex = 0;
        }
        
        // Increment hop index for each response in this section
        hopIndex++;
        final hopNumber = hopIndex;
        
        final address = data['address'] ?? '';
        final lastValue = data['last'] ?? '';
        final isTimeout = lastValue == 'timeout' || (address.isEmpty && lastValue == '0');
        
        // Parse RTT values (in milliseconds, can be decimal like "0.8")
        Duration? rtt1, rtt2, rtt3;
        if (!isTimeout && address.isNotEmpty) {
          if (data['best'] != null && data['best']!.isNotEmpty) {
            rtt1 = _parseMilliseconds(data['best']!);
          }
          if (data['avg'] != null && data['avg']!.isNotEmpty) {
            rtt2 = _parseMilliseconds(data['avg']!);
          }
          if (data['worst'] != null && data['worst']!.isNotEmpty) {
            rtt3 = _parseMilliseconds(data['worst']!);
          }
        }
        
        final isReachable = address.isNotEmpty && !isTimeout;
        
        // Create hop
        final hop = TracerouteHop(
          hopNumber: hopNumber,
          ipAddress: address.isNotEmpty ? address : null,
          hostname: data['name']?.isNotEmpty == true ? data['name'] : null,
          rtt1: rtt1,
          rtt2: rtt2,
          rtt3: rtt3,
          isReachable: isReachable,
          status: isTimeout ? 'timeout' : null,
        );
        
        // Update hop map - prefer reachable hops over timeout
        final existingHop = hopMap[hopNumber];
        if (existingHop == null || 
            (isReachable && !existingHop.isReachable) ||
            (isReachable && rtt1 != null)) {
          hopMap[hopNumber] = hop;
          
          // Yield the updated hop
          yield hop;
        }
      }
    } catch (e) {
      throw ServerException('Failed to perform streaming traceroute: $e');
    }
  }
  
  /// Parse milliseconds value (can be integer or decimal like "0.3", "1", "10.5")
  static Duration? _parseMilliseconds(String value) {
    final ms = double.tryParse(value);
    if (ms == null) return null;
    return Duration(microseconds: (ms * 1000).round());
  }

  /// Stop traceroute stream
  @override
  Future<Either<Failure, void>> stopTraceroute() async {
    try {
      // Use legacy client to stop streaming
      await legacyClient.stopStreaming();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to stop traceroute: $e'));
    }
  }

  @override
  Future<Either<Failure, DnsLookupResult>> dnsLookup({
    required String domain,
    int timeout = 5000,
  }) async {
    try {
      final response = await routerOsClient.dnsLookup(
        name: domain,
      );

      final model = DnsLookupResultModel.fromRouterOS(domain, response);
      return Right(model.toEntity());
    } on ServerException {
      return Left(const ServerFailure('Failed to perform DNS lookup'));
    }
  }
}