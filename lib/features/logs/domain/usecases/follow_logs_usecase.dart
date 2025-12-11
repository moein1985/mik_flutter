import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log_entry.dart';
import '../repositories/logs_repository.dart';

/// Use case for following logs in real-time
class FollowLogsUseCase {
  final LogsRepository repository;

  FollowLogsUseCase(this.repository);

  /// Follow logs in real-time with optional filtering
  Stream<Either<Failure, LogEntry>> call({
    String? topics,
  }) {
    return repository.followLogs(
      topics: topics,
    );
  }

  /// Stop following logs
  Future<void> stop() async {
    await repository.stopFollowingLogs();
  }
}