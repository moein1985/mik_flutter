import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ping_result.dart';
import '../repositories/tools_repository.dart';

/// Use case for ping operations
class PingUseCase {
  final ToolsRepository repository;

  PingUseCase(this.repository);

  /// Execute ping operation
  Future<Either<Failure, PingResult>> call({
    required String target,
    int count = 4,
    int timeout = 1000,
  }) async {
    return await repository.ping(
      target: target,
      count: count,
      timeout: timeout,
    );
  }

  /// Stop ongoing ping operation
  Future<Either<Failure, void>> stop() async {
    return await repository.stopPing();
  }

  /// Execute continuous ping operation with streaming updates
  /// Returns a stream that emits ping results as packets arrive
  Stream<PingResult> callStream({
    required String target,
    int interval = 1,
    int timeout = 1000,
  }) {
    return repository.pingStream(
      target: target,
      interval: interval,
      timeout: timeout,
    );
  }
}