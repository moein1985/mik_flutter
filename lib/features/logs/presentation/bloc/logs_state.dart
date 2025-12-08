import 'package:equatable/equatable.dart';
import '../../domain/entities/log_entry.dart';

abstract class LogsState extends Equatable {
  const LogsState();

  @override
  List<Object?> get props => [];
}

class LogsInitial extends LogsState {
  const LogsInitial();
}

class LogsLoading extends LogsState {
  const LogsLoading();
}

class LogsLoaded extends LogsState {
  final List<LogEntry> logs;
  final bool isFollowing;
  final String? currentFilter;

  const LogsLoaded({
    required this.logs,
    this.isFollowing = false,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [logs, isFollowing, currentFilter];
}

class LogsError extends LogsState {
  final String message;

  const LogsError(this.message);

  @override
  List<Object?> get props => [message];
}

class LogsFollowing extends LogsState {
  final List<LogEntry> logs;
  final String? currentFilter;

  const LogsFollowing({
    required this.logs,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [logs, currentFilter];
}

class LogsOperationSuccess extends LogsState {
  final String message;

  const LogsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}