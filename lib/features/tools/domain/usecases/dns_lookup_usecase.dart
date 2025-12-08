import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dns_lookup_result.dart';
import '../repositories/tools_repository.dart';

/// Use case for DNS lookup operations
class DnsLookupUseCase {
  final ToolsRepository repository;

  DnsLookupUseCase(this.repository);

  /// Execute DNS lookup operation
  Future<Either<Failure, DnsLookupResult>> call({
    required String domain,
    int timeout = 5000,
  }) async {
    return await repository.dnsLookup(
      domain: domain,
      timeout: timeout,
    );
  }
}