import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log_entry.dart';

abstract class LogsRepository {
  /// Get logs with optional filtering
  Future<Either<Failure, List<LogEntry>>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  });

  /// Follow logs in real-time (streaming)
  Stream<Either<Failure, LogEntry>> followLogs({
    String? topics,
  });

  /// Stop following logs
  void stopFollowingLogs();

  /// Clear all logs
  Future<Either<Failure, void>> clearLogs();

  /// Search logs by text
  Future<Either<Failure, List<LogEntry>>> searchLogs({
    required String query,
    int? count,
    String? topics,
  });
}