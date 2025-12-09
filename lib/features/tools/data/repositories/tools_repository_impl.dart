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