import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/log_entry.dart';
import '../../domain/repositories/logs_repository.dart';

/// Fake implementation of LogsRepository for development without a real router
class FakeLogsRepositoryImpl implements LogsRepository {
  // In-memory log store
  final List<LogEntry> _logs = [];
  
  // Stream controller for following logs
  StreamController<Either<Failure, LogEntry>>? _logStreamController;
  Timer? _logGeneratorTimer;

  FakeLogsRepositoryImpl() {
    _initializeLogs();
  }

  void _initializeLogs() {
    // Generate 50 fake log entries
    final now = DateTime.now();
    final topics = ['system', 'firewall', 'wireless', 'dhcp', 'interface', 'script'];
    final levels = [LogLevel.info, LogLevel.warning, LogLevel.error];
    
    for (int i = 0; i < 50; i++) {
      final time = now.subtract(Duration(minutes: 50 - i, seconds: i * 3));
      final topic = topics[i % topics.length];
      final level = levels[i % levels.length];
      
      String message;
      switch (topic) {
        case 'system':
          message = i % 3 == 0 
              ? 'System time synchronized' 
              : 'Router uptime: ${i + 1} days';
          break;
        case 'firewall':
          message = 'Connection established: 192.168.88.${100 + (i % 50)}:${8000 + i}';
          break;
        case 'wireless':
          message = 'Client AA:BB:CC:DD:EE:${i.toRadixString(16).padLeft(2, '0')} connected';
          break;
        case 'dhcp':
          message = 'DHCP lease assigned: 192.168.88.${100 + (i % 50)}';
          break;
        case 'interface':
          message = 'Interface ether${(i % 3) + 1} link ${i % 2 == 0 ? "up" : "down"}';
          break;
        default:
          message = 'Script execution completed';
      }
      
      _logs.add(LogEntry(
        id: i.toString(),
        time: time.toIso8601String(),
        topics: topic,
        message: message,
        level: level,
      ));
    }
  }

  Future<void> _simulateDelay() => Future.delayed(AppConfig.fakeNetworkDelay);

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  @override
  Future<Either<Failure, List<LogEntry>>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load logs'));
    }

    var filteredLogs = List<LogEntry>.from(_logs);

    // Filter by topics
    if (topics != null && topics.isNotEmpty) {
      filteredLogs = filteredLogs
          .where((log) => log.topics?.contains(topics) ?? false)
          .toList();
    }

    // Filter by time range (simplified)
    if (since != null) {
      final sinceDate = DateTime.tryParse(since);
      if (sinceDate != null) {
        filteredLogs = filteredLogs
            .where((log) => 
                DateTime.tryParse(log.time ?? '')?.isAfter(sinceDate) ?? false)
            .toList();
      }
    }

    if (until != null) {
      final untilDate = DateTime.tryParse(until);
      if (untilDate != null) {
        filteredLogs = filteredLogs
            .where((log) => 
                DateTime.tryParse(log.time ?? '')?.isBefore(untilDate) ?? false)
            .toList();
      }
    }

    // Limit count
    if (count != null && count > 0 && filteredLogs.length > count) {
      filteredLogs = filteredLogs.sublist(filteredLogs.length - count);
    }

    return Right(filteredLogs);
  }

  @override
  Stream<Either<Failure, LogEntry>> followLogs({String? topics}) {
    _logStreamController = StreamController<Either<Failure, LogEntry>>();

    // Simulate new log entries every 2-5 seconds
    _logGeneratorTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_shouldSimulateError()) {
        _logStreamController?.add(
            const Left(ServerFailure('Connection lost while following logs')));
        return;
      }

      final now = DateTime.now();
      final logTopics = ['system', 'firewall', 'wireless', 'dhcp', 'interface'];
      final topic = logTopics[timer.tick % logTopics.length];
      
      // Skip if filtering and topic doesn't match
      if (topics != null && topics.isNotEmpty && !topic.contains(topics)) {
        return;
      }

      final newLog = LogEntry(
        id: (_logs.length + timer.tick).toString(),
        time: now.toIso8601String(),
        topics: topic,
        message: 'New log entry at ${now.toLocal()}',
        level: LogLevel.info,
      );

      _logs.add(newLog);
      _logStreamController?.add(Right(newLog));
    });

    return _logStreamController!.stream;
  }

  @override
  Future<void> stopFollowingLogs() async {
    _logGeneratorTimer?.cancel();
    await _logStreamController?.close();
    _logStreamController = null;
  }

  @override
  Future<Either<Failure, void>> clearLogs() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to clear logs'));
    }

    _logs.clear();
    _initializeLogs(); // Re-initialize with fresh logs
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<LogEntry>>> searchLogs({
    required String query,
    int? count,
    String? topics,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to search logs'));
    }

    var filteredLogs = _logs.where((log) {
      final matchesQuery = log.message?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final matchesTopic = topics == null || 
          topics.isEmpty || 
          (log.topics?.contains(topics) ?? false);
      return matchesQuery && matchesTopic;
    }).toList();

    // Limit count
    if (count != null && count > 0 && filteredLogs.length > count) {
      filteredLogs = filteredLogs.sublist(filteredLogs.length - count);
    }

    return Right(filteredLogs);
  }

  void dispose() {
    stopFollowingLogs();
  }
}
