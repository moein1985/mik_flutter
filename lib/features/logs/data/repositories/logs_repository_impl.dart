import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/log_entry.dart';
import '../../domain/repositories/logs_repository.dart';
import '../datasources/logs_remote_data_source.dart';

/// Implementation of LogsRepository
class LogsRepositoryImpl implements LogsRepository {
  final LogsRemoteDataSource remoteDataSource;

  LogsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LogEntry>>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  }) async {
    try {
      final result = await remoteDataSource.getLogs(
        count: count,
        topics: topics,
        since: since,
        until: until,
      );
      return Right(result);
    } on ServerException {
      return Left(const ServerFailure('Failed to get logs'));
    }
  }

  @override
  Stream<Either<Failure, LogEntry>> followLogs({
    String? topics,
  }) async* {
    try {
      await for (final logEntry in remoteDataSource.followLogs(
        topics: topics,
      )) {
        yield Right(logEntry);
      }
    } catch (e) {
      yield Left(const ServerFailure('Failed to follow logs'));
    }
  }

  @override
  void stopFollowingLogs() {
    remoteDataSource.stopFollowingLogs();
  }

  @override
  Future<Either<Failure, void>> clearLogs() async {
    try {
      await remoteDataSource.clearLogs();
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to clear logs'));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> searchLogs({
    required String query,
    int? count,
    String? topics,
  }) async {
    try {
      final result = await remoteDataSource.searchLogs(
        query: query,
        count: count,
        topics: topics,
      );
      return Right(result);
    } on ServerException {
      return Left(const ServerFailure('Failed to search logs'));
    }
  }
}