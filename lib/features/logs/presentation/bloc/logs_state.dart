import 'package:equatable/equatable.dart';
import '../../domain/entities/log_entry.dart';

sealed class LogsState extends Equatable {
  const LogsState();

  @override
  List<Object?> get props => [];
}

final class LogsInitial extends LogsState {
  const LogsInitial();
}

final class LogsLoading extends LogsState {
  const LogsLoading();
}

final class LogsLoaded extends LogsState {
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

final class LogsError extends LogsState {
  final String message;

  const LogsError(this.message);

  @override
  List<Object?> get props => [message];
}

final class LogsFollowing extends LogsState {
  final List<LogEntry> logs;
  final String? currentFilter;

  const LogsFollowing({
    required this.logs,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [logs, currentFilter];
}

final class LogsOperationSuccess extends LogsState {
  final String message;

  const LogsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}