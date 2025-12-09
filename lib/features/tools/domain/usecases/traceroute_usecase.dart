import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/traceroute_hop.dart';
import '../repositories/tools_repository.dart';

/// Use case for traceroute operations
class TracerouteUseCase {
  final ToolsRepository repository;

  TracerouteUseCase(this.repository);

  /// Execute traceroute operation
  Future<Either<Failure, List<TracerouteHop>>> call({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  }) async {
    return await repository.traceroute(
      target: target,
      maxHops: maxHops,
      timeout: timeout,
    );
  }

  /// Execute traceroute operation with streaming updates
  /// Returns a stream that emits hops as they are discovered
  Stream<TracerouteHop> callStream({
    required String target,
    int maxHops = 30,
    int timeout = 1000,
  }) {
    return repository.tracerouteStream(
      target: target,
      maxHops: maxHops,
      timeout: timeout,
    );
  }
}