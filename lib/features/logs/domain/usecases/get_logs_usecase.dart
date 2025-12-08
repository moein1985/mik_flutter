import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log_entry.dart';
import '../repositories/logs_repository.dart';

/// Use case for getting logs
class GetLogsUseCase {
  final LogsRepository repository;

  GetLogsUseCase(this.repository);

  /// Get logs with optional filtering
  Future<Either<Failure, List<LogEntry>>> call({
    int? count,
    String? topics,
    String? since,
    String? until,
  }) async {
    return await repository.getLogs(
      count: count,
      topics: topics,
      since: since,
      until: until,
    );
  }
}