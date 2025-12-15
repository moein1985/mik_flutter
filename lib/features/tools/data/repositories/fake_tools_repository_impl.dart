import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../../domain/entities/ping_result.dart';
import '../../domain/entities/traceroute_hop.dart';
import '../../domain/repositories/tools_repository.dart';

/// Fake implementation of ToolsRepository for development without a real router
class FakeToolsRepositoryImpl implements ToolsRepository {
  final _random = Random();
  StreamController<PingResult>? _pingStreamController;
  StreamController<TracerouteHop>? _tracerouteStreamController;
  Timer? _pingTimer;
  Timer? _tracerouteTimer;
  bool _isPingRunning = false;
  bool _isTracerouteRunning = false;

  // Simulated network parameters
  final List<String> _simulatedRoute = [
    '192.168.1.1',
    '10.0.0.1',
    '172.16.0.1',
    '8.8.8.8',
  ];

  Future<void> _simulateDelay() async {
    final delay = Duration(
      milliseconds: AppConfig.fakeMinDelay.inMilliseconds +
          _random.nextInt(
            AppConfig.fakeMaxDelay.inMilliseconds -
                AppConfig.fakeMinDelay.inMilliseconds,
          ),
    );
    await Future.delayed(delay);
  }

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  Duration _generateRtt({int minMs = 10, int maxMs = 100}) {
    return Duration(milliseconds: minMs + _random.nextInt(maxMs - minMs));
  }

  @override
  Future<Either<Failure, PingResult>> ping({
    required String target,
    int count = 4,
    int timeout = 1000,
  }) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to ping target'));
    }

    // Simulate ping operation with random packet loss
    final packetsReceived = count - _random.nextInt(count ~/ 4);
    final rttList = List.generate(
      packetsReceived,
      (_) => _generateRtt(),
    );

    if (rttList.isEmpty) {
      return Left(ServerFailure('100% packet loss to $target'));
    }

    final minRtt = rttList.reduce((a, b) => a < b ? a : b);
    final maxRtt = rttList.reduce((a, b) => a > b ? a : b);
    final avgRtt = Duration(
      microseconds: rttList.fold<int>(0, (sum, rtt) => sum + rtt.inMicroseconds) ~/ rttList.length,
    );

    final packets = List.generate(count, (i) {
      final received = i < packetsReceived;
      return PingPacket(
        sequence: i + 1,
        rtt: received ? rttList[i] : null,
        received: received,
      );
    });

    return Right(PingResult(
      target: target,
      packetsSent: count,
      packetsReceived: packetsReceived,
      packetLossPercent: ((count - packetsReceived) / count * 100).round(),
      minRtt: minRtt,
      avgRtt: avgRtt,
      maxRtt: maxRtt,
      packets: packets,
    ));
  }

  @override
  Future<Either<Failure, void>> stopPing() async {
    _isPingRunning = false;
    _pingTimer?.cancel();
    _pingStreamController?.close();
    _pingStreamController = null;
    return const Right(null);
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
  }) {
    // Cancel any existing ping
    stopPing();

    _pingStreamController = StreamController<PingResult>();
    _isPingRunning = true;

    int sent = 0;
    int received = 0;
    final rttList = <Duration>[];
    final packets = <PingPacket>[];

    // Simulate initial ping delay
    Future.delayed(Duration(milliseconds: _random.nextInt(200) + 100), () {
      _pingTimer = Timer.periodic(Duration(seconds: interval), (timer) {
        if (!_isPingRunning || sent >= count) {
          timer.cancel();
          _pingStreamController?.close();
          return;
        }

        sent++;
        
        // Simulate 5-10% packet loss
        final isReceived = _random.nextDouble() > 0.07;
        final rtt = isReceived ? _generateRtt(minMs: 15, maxMs: 150) : null;

        if (isReceived && rtt != null) {
          received++;
          rttList.add(rtt);
        }

        final packet = PingPacket(
          sequence: sent,
          rtt: rtt,
          received: isReceived,
        );
        packets.add(packet);

        final minRtt = rttList.isEmpty ? Duration.zero : rttList.reduce((a, b) => a < b ? a : b);
        final maxRtt = rttList.isEmpty ? Duration.zero : rttList.reduce((a, b) => a > b ? a : b);
        final avgRtt = rttList.isEmpty
            ? Duration.zero
            : Duration(
                microseconds: rttList.fold<int>(0, (sum, rtt) => sum + rtt.inMicroseconds) ~/ rttList.length,
              );

        final result = PingResult(
          target: target,
          packetsSent: sent,
          packetsReceived: received,
          packetLossPercent: ((sent - received) / sent * 100).round(),
          minRtt: minRtt,
          avgRtt: avgRtt,
          maxRtt: maxRtt,
          isRunning: sent < count,
          packets: List.from(packets),
        );

        if (_pingStreamController?.isClosed == false) {
          _pingStreamController?.add(result);
        }
      });
    });

    return _pingStreamController!.stream;
  }

  @override
  Future<Either<Failure, List<TracerouteHop>>> traceroute({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  }) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to traceroute target'));
    }

    // Simulate traceroute with realistic hop count (3-8 hops typically)
    final hopCount = 3 + _random.nextInt(6);
    final hops = <TracerouteHop>[];

    for (int i = 0; i < hopCount; i++) {
      final hopNumber = i + 1;
      final isLastHop = i == hopCount - 1;
      
      // Simulate occasional unreachable hop
      final isReachable = _random.nextDouble() > 0.05;

      if (isReachable) {
        final ipAddress = isLastHop ? target : _simulatedRoute[i % _simulatedRoute.length];
        hops.add(TracerouteHop(
          hopNumber: hopNumber,
          ipAddress: ipAddress,
          hostname: isLastHop ? target : 'hop-$hopNumber.network.local',
          rtt1: _generateRtt(minMs: hopNumber * 5, maxMs: hopNumber * 15 + 50),
          rtt2: _generateRtt(minMs: hopNumber * 5, maxMs: hopNumber * 15 + 50),
          rtt3: _generateRtt(minMs: hopNumber * 5, maxMs: hopNumber * 15 + 50),
          isReachable: true,
        ));
      } else {
        hops.add(TracerouteHop(
          hopNumber: hopNumber,
          isReachable: false,
          status: '* * * Request timed out',
        ));
      }
    }

    return Right(hops);
  }

  @override
  Future<Either<Failure, void>> stopTraceroute() async {
    _isTracerouteRunning = false;
    _tracerouteTimer?.cancel();
    _tracerouteStreamController?.close();
    _tracerouteStreamController = null;
    return const Right(null);
  }

  @override
  Stream<TracerouteHop> tracerouteStream({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  }) {
    // Cancel any existing traceroute
    stopTraceroute();

    _tracerouteStreamController = StreamController<TracerouteHop>();
    _isTracerouteRunning = true;

    // Simulate realistic hop count
    final hopCount = 3 + _random.nextInt(6);
    int currentHop = 0;

    // Start after initial delay
    Future.delayed(Duration(milliseconds: _random.nextInt(300) + 200), () {
      _tracerouteTimer = Timer.periodic(
        Duration(milliseconds: 800 + _random.nextInt(400)),
        (timer) {
          if (!_isTracerouteRunning || currentHop >= hopCount) {
            timer.cancel();
            _tracerouteStreamController?.close();
            return;
          }

          currentHop++;
          final isLastHop = currentHop == hopCount;
          
          // Simulate occasional unreachable hop (5% chance)
          final isReachable = _random.nextDouble() > 0.05;

          TracerouteHop hop;
          if (isReachable) {
            final ipAddress = isLastHop ? target : _simulatedRoute[currentHop - 1 % _simulatedRoute.length];
            hop = TracerouteHop(
              hopNumber: currentHop,
              ipAddress: ipAddress,
              hostname: isLastHop ? target : 'hop-$currentHop.network.local',
              rtt1: _generateRtt(minMs: currentHop * 5, maxMs: currentHop * 15 + 50),
              rtt2: _generateRtt(minMs: currentHop * 5, maxMs: currentHop * 15 + 50),
              rtt3: _generateRtt(minMs: currentHop * 5, maxMs: currentHop * 15 + 50),
              isReachable: true,
            );
          } else {
            hop = TracerouteHop(
              hopNumber: currentHop,
              isReachable: false,
              status: '* * * Request timed out',
            );
          }

          if (_tracerouteStreamController?.isClosed == false) {
            _tracerouteStreamController?.add(hop);
          }
        },
      );
    });

    return _tracerouteStreamController!.stream;
  }

  @override
  Future<Either<Failure, DnsLookupResult>> dnsLookup({
    required String domain,
    int timeout = 5000,
    String? recordType,
    String? dnsServer,
  }) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to resolve domain: $domain'));
    }

    // Simulate realistic DNS response
    final responseTime = _generateRtt(minMs: 20, maxMs: 200);

    // Generate fake IP addresses based on record type
    final type = recordType?.toUpperCase() ?? 'A';
    
    List<String> ipv4Addresses = [];
    List<String> ipv6Addresses = [];
    List<String> otherRecords = [];

    switch (type) {
      case 'A':
        // Generate 1-3 IPv4 addresses
        final count = 1 + _random.nextInt(3);
        ipv4Addresses = List.generate(
          count,
          (_) => '${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(256)}',
        );
        break;
        
      case 'AAAA':
        // Generate 1-2 IPv6 addresses
        final count = 1 + _random.nextInt(2);
        ipv6Addresses = List.generate(
          count,
          (_) {
            final hex = List.generate(8, (_) => _random.nextInt(65536).toRadixString(16).padLeft(4, '0'));
            return hex.join(':');
          },
        );
        break;
        
      case 'MX':
        otherRecords = [
          '10 mail1.$domain',
          '20 mail2.$domain',
        ];
        break;
        
      case 'NS':
        otherRecords = [
          'ns1.$domain',
          'ns2.$domain',
        ];
        break;
        
      case 'TXT':
        otherRecords = [
          'v=spf1 include:_spf.$domain ~all',
          'google-site-verification=randomstring123',
        ];
        break;
        
      case 'CNAME':
        otherRecords = ['alias.$domain'];
        break;
        
      case 'ANY':
        // Return multiple record types
        ipv4Addresses = ['${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(256)}'];
        ipv6Addresses = ['2001:db8::${_random.nextInt(10)}'];
        otherRecords = [
          'MX: 10 mail.$domain',
          'NS: ns1.$domain',
          'TXT: v=spf1 include:_spf.$domain ~all',
        ];
        break;
    }

    return Right(DnsLookupResult(
      domain: domain,
      ipv4Addresses: ipv4Addresses,
      ipv6Addresses: ipv6Addresses,
      otherRecords: otherRecords,
      responseTime: responseTime,
      recordType: type,
      dnsServer: dnsServer ?? '8.8.8.8',
    ));
  }

  void dispose() {
    stopPing();
    stopTraceroute();
  }
}
