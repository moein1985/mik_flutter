import 'package:equatable/equatable.dart';

abstract class LogsEvent extends Equatable {
  const LogsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLogs extends LogsEvent {
  final int? count;
  final String? topics;
  final String? since;
  final String? until;

  const LoadLogs({
    this.count,
    this.topics,
    this.since,
    this.until,
  });

  @override
  List<Object?> get props => [count, topics, since, until];
}

class StartFollowingLogs extends LogsEvent {
  final String? topics;
  final Duration? timeout;

  const StartFollowingLogs({
    this.topics,
    this.timeout,
  });

  @override
  List<Object?> get props => [topics, timeout];
}

class StopFollowingLogs extends LogsEvent {
  const StopFollowingLogs();
}

class ClearLogs extends LogsEvent {
  const ClearLogs();
}

class SearchLogs extends LogsEvent {
  final String query;
  final int? count;
  final String? topics;

  const SearchLogs({
    required this.query,
    this.count,
    this.topics,
  });

  @override
  List<Object?> get props => [query, count, topics];
}

class RefreshLogs extends LogsEvent {
  const RefreshLogs();
}