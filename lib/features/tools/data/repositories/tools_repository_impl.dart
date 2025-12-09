import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../../domain/entities/ping_result.dart';
import '../../domain/entities/traceroute_hop.dart';
import '../../domain/repositories/tools_repository.dart';
import '../../../../core/network/routeros_client.dart';
import '../models/dns_lookup_result_model.dart';
import '../models/ping_result_model.dart';
import '../models/traceroute_hop_model.dart';

/// Implementation of ToolsRepository
class ToolsRepositoryImpl implements ToolsRepository {
  final RouterOSClient routerOsClient;

  ToolsRepositoryImpl({required this.routerOsClient});

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
        timeout: timeout,
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
      // Stop is handled by cancelling the stream subscription
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to stop ping'));
    }
  }

  @override
  Stream<PingResult> pingStream({
    required String target,
    int interval = 1,
    int timeout = 1000,
  }) async* {
    try {
      int packetsSent = 0;
      int packetsReceived = 0;
      Duration minRtt = Duration.zero;
      Duration avgRtt = Duration.zero;
      Duration maxRtt = Duration.zero;
      final packets = <PingPacket>[];
      
      await for (final data in routerOsClient.pingStream(
        address: target,
        interval: interval,
        timeout: timeout,
      )) {
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
      var hopIndex = 0;
      
      await for (final data in routerOsClient.tracerouteStream(
        address: target,
        maxHops: maxHops,
        timeout: timeout,
      )) {
        // Convert each hop update to entity and yield it
        final hop = TracerouteHopModel.fromRouterOS(data, hopIndex).toEntity();
        yield hop;
        hopIndex++;
      }
    } catch (e) {
      throw ServerException('Failed to perform streaming traceroute: $e');
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
        timeout: timeout,
      );

      final model = DnsLookupResultModel.fromRouterOS(domain, response);
      return Right(model.toEntity());
    } on ServerException {
      return Left(const ServerFailure('Failed to perform DNS lookup'));
    }
  }
}