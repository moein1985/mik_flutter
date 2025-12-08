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
}