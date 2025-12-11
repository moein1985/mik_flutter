import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/log_entry.dart';
import '../models/log_entry_model.dart';

final _log = AppLogger.tag('LogsDataSource');

abstract class LogsRemoteDataSource {
  Future<List<LogEntry>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  });

  Stream<LogEntry> followLogs({
    String? topics,
  });

  Future<void> stopFollowingLogs();

  Future<void> clearLogs();

  Future<List<LogEntry>> searchLogs({
    required String query,
    int? count,
    String? topics,
  });
}

class LogsRemoteDataSourceImpl implements LogsRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  LogsRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get client {
    if (authRemoteDataSource.legacyClient == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.legacyClient!;
  }

  @override
  Future<List<LogEntry>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  }) async {
    final result = await client.getLogs(
      count: count,
      topics: topics,
      since: since,
      until: until,
    );
    return result.map((map) => LogEntryModel.fromJson(map)).toList();
  }

  @override
  Stream<LogEntry> followLogs({
    String? topics,
  }) async* {
    _log.i('followLogs called with topics: $topics');
    // Use legacy client's followLogs which handles encoding correctly
    final stream = await client.followLogs(topics: topics);
    _log.i('Stream started');
    
    await for (final logMap in stream) {
      _log.d('Received log data: $logMap');
      // Skip dead/deleted log entries (they only have .id and .dead fields)
      if (logMap['.dead'] == 'true') {
        continue;
      }
      // Skip entries without message (invalid logs)
      if (logMap['message'] == null) {
        _log.w('Skipping log without message: $logMap');
        continue;
      }
      yield LogEntryModel.fromJson(logMap);
    }
    _log.i('Stream ended');
  }

  @override
  Future<void> stopFollowingLogs() async {
    await client.stopStreaming();
  }

  @override
  Future<void> clearLogs() async {
    await client.clearLogs();
  }

  @override
  Future<List<LogEntry>> searchLogs({
    required String query,
    int? count,
    String? topics,
  }) async {
    // Search logs by filtering local results
    final allLogs = await getLogs(count: count, topics: topics);
    final queryLower = query.toLowerCase();
    return allLogs.where((log) => 
      (log.message?.toLowerCase().contains(queryLower) ?? false) ||
      (log.topics?.toLowerCase().contains(queryLower) ?? false)
    ).toList();
  }
}