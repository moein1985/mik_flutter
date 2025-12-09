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
  });
}