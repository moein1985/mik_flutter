import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log_entry.dart';
import '../repositories/logs_repository.dart';

/// Use case for searching logs
class SearchLogsUseCase {
  final LogsRepository repository;

  SearchLogsUseCase(this.repository);

  /// Search logs by text with optional filtering
  Future<Either<Failure, List<LogEntry>>> call({
    required String query,
    int? count,
    String? topics,
  }) async {
    return await repository.searchLogs(
      query: query,
      count: count,
      topics: topics,
    );
  }
}