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
      // TODO: Implement stop ping command
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to stop ping'));
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

      // Filter: only parse first section (section=0) to avoid duplicates
      // RouterOS sends multiple sections when count > 1, we only want the first trace
      final hops = <TracerouteHop>[];
      for (var i = 0; i < response.length; i++) {
        final data = response[i];
        // Skip done messages
        if (data['type'] == 'done') continue;
        // Only parse first section - check both string '0' and ensure it exists
        final section = data['.section'];
        if (section != '0' && section != null) continue;
        // Also stop if we see section 1 (moved to next trace)
        if (section == '1') break;
        
        hops.add(TracerouteHopModel.fromRouterOS(data, hops.length).toEntity());
      }

      return Right(hops);
    } on ServerException {
      return Left(const ServerFailure('Failed to perform traceroute'));
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