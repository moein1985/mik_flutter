import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/log_entry.dart';
import '../../domain/usecases/clear_logs_usecase.dart';
import '../../domain/usecases/follow_logs_usecase.dart';
import '../../domain/usecases/get_logs_usecase.dart';
import '../../domain/usecases/search_logs_usecase.dart';
import 'logs_event.dart';
import 'logs_state.dart';

class LogsBloc extends Bloc<LogsEvent, LogsState> {
  final GetLogsUseCase getLogsUseCase;
  final FollowLogsUseCase followLogsUseCase;
  final ClearLogsUseCase clearLogsUseCase;
  final SearchLogsUseCase searchLogsUseCase;

  StreamSubscription? _logsSubscription;

  LogsBloc({
    required this.getLogsUseCase,
    required this.followLogsUseCase,
    required this.clearLogsUseCase,
    required this.searchLogsUseCase,
  }) : super(const LogsInitial()) {
    on<LoadLogs>(_onLoadLogs);
    on<StartFollowingLogs>(_onStartFollowingLogs);
    on<StopFollowingLogs>(_onStopFollowingLogs);
    on<ClearLogs>(_onClearLogs);
    on<SearchLogs>(_onSearchLogs);
    on<RefreshLogs>(_onRefreshLogs);
  }

  Future<void> _onLoadLogs(LoadLogs event, Emitter<LogsState> emit) async {
    emit(const LogsLoading());

    final result = await getLogsUseCase.call(
      count: event.count,
      topics: event.topics,
      since: event.since,
      until: event.until,
    );

    result.fold(
      (failure) => emit(LogsError(failure.message)),
      (logs) => emit(LogsLoaded(
        logs: logs,
        currentFilter: event.topics,
      )),
    );
  }

  Future<void> _onStartFollowingLogs(StartFollowingLogs event, Emitter<LogsState> emit) async {
    // Stop any existing subscription
    await _logsSubscription?.cancel();

    final currentLogs = state is LogsLoaded
        ? (state as LogsLoaded).logs
        : <LogEntry>[];

    emit(LogsFollowing(
      logs: currentLogs,
      currentFilter: event.topics,
    ));

    _logsSubscription = followLogsUseCase.call(
      topics: event.topics,
      timeout: event.timeout,
    ).listen(
      (result) {
        result.fold(
          (failure) {
            add(const StopFollowingLogs());
            emit(LogsError(failure.message));
          },
          (logEntry) {
            if (state is LogsFollowing) {
              final currentState = state as LogsFollowing;
              final updatedLogs = [logEntry, ...currentState.logs];
              emit(LogsFollowing(
                logs: updatedLogs,
                currentFilter: currentState.currentFilter,
              ));
            }
          },
        );
      },
      onError: (error) {
        add(const StopFollowingLogs());
        emit(const LogsError('Failed to follow logs'));
      },
      onDone: () {
        add(const StopFollowingLogs());
      },
    );
  }

  Future<void> _onStopFollowingLogs(StopFollowingLogs event, Emitter<LogsState> emit) async {
    await _logsSubscription?.cancel();
    _logsSubscription = null;

    if (state is LogsFollowing) {
      final currentState = state as LogsFollowing;
      emit(LogsLoaded(
        logs: currentState.logs,
        isFollowing: false,
        currentFilter: currentState.currentFilter,
      ));
    }
  }

  Future<void> _onClearLogs(ClearLogs event, Emitter<LogsState> emit) async {
    final result = await clearLogsUseCase.call();

    result.fold(
      (failure) => emit(LogsError(failure.message)),
      (_) {
        emit(const LogsOperationSuccess('Logs cleared successfully'));
        // Reload logs after clearing
        add(const LoadLogs());
      },
    );
  }

  Future<void> _onSearchLogs(SearchLogs event, Emitter<LogsState> emit) async {
    emit(const LogsLoading());

    final result = await searchLogsUseCase.call(
      query: event.query,
      count: event.count,
      topics: event.topics,
    );

    result.fold(
      (failure) => emit(LogsError(failure.message)),
      (logs) => emit(LogsLoaded(
        logs: logs,
        currentFilter: 'Search: ${event.query}',
      )),
    );
  }

  Future<void> _onRefreshLogs(RefreshLogs event, Emitter<LogsState> emit) async {
    add(const LoadLogs());
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}