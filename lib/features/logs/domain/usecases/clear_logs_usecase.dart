import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/logs_repository.dart';

/// Use case for clearing logs
class ClearLogsUseCase {
  final LogsRepository repository;

  ClearLogsUseCase(this.repository);

  /// Clear all logs
  Future<Either<Failure, void>> call() async {
    return await repository.clearLogs();
  }
}