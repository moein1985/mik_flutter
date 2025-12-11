import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ping_result.dart';
import '../entities/traceroute_hop.dart';
import '../entities/dns_lookup_result.dart';

/// Repository interface for diagnostic tools
abstract class ToolsRepository {
  /// Perform ping operation
  Future<Either<Failure, PingResult>> ping({
    required String target,
    int count = 4,
    int timeout = 1000,
  });

  /// Stop ongoing ping operation
  Future<Either<Failure, void>> stopPing();

  /// Stop ongoing traceroute operation
  Future<Either<Failure, void>> stopTraceroute();

  /// Perform continuous ping operation with streaming updates
  /// Emits ping results as packets arrive in real-time
  /// 
  /// Parameters:
  /// - [target]: Target IP or hostname
  /// - [interval]: Interval between packets in seconds (default: 1)
  /// - [count]: Number of packets to send (default: 100 for continuous)
  /// - [size]: Packet size in bytes (default: 56)
  /// - [ttl]: Time to live (default: 64)
  /// - [srcAddress]: Source address (default: auto)
  /// - [interfaceName]: Interface to use (default: auto)
  /// - [doNotFragment]: Set DF flag (default: false)
  Stream<PingResult> pingStream({
    required String target,
    int interval = 1,
    int count = 100,
    int? size,
    int? ttl,
    String? srcAddress,
    String? interfaceName,
    bool doNotFragment = false,
  });

  /// Perform traceroute operation
  Future<Either<Failure, List<TracerouteHop>>> traceroute({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  });

  /// Perform traceroute operation with streaming updates
  /// Emits hop information as it arrives in real-time
  Stream<TracerouteHop> tracerouteStream({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  });

  /// Perform DNS lookup
  Future<Either<Failure, DnsLookupResult>> dnsLookup({
    required String domain,
    int timeout = 5000,
    String? recordType,
    String? dnsServer,
  });
}