import '../../../../core/network/routeros_client.dart';
import '../../domain/entities/log_entry.dart';
import '../models/log_entry_model.dart';

abstract class LogsRemoteDataSource {
  Future<List<LogEntry>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  });

  Stream<LogEntry> followLogs({
    String? topics,
    Duration? timeout,
  });

  Future<void> clearLogs();

  Future<List<LogEntry>> searchLogs({
    required String query,
    int? count,
    String? topics,
  });
}

class LogsRemoteDataSourceImpl implements LogsRemoteDataSource {
  final RouterOSClient client;

  LogsRemoteDataSourceImpl(this.client);

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
    Duration? timeout,
  }) async* {
    await for (final logMap in client.followLogs(
      topics: topics,
      timeout: timeout,
    )) {
      yield LogEntryModel.fromJson(logMap);
    }
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
    final result = await client.searchLogs(
      query: query,
      count: count,
      topics: topics,
    );
    return result.map((map) => LogEntryModel.fromJson(map)).toList();
  }
}