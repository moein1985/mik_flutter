import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
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
      count: event.count, // بدون محدودیت - همه لاگ‌ها
      topics: event.topics,
      since: event.since,
      until: event.until,
    );

    result.fold(
      (failure) => emit(LogsError(failure.message)),
      (logs) {
        // معکوس کردن لیست: قدیمی‌ترین بالا، جدیدترین پایین
        final reversedLogs = logs.reversed.toList();
        emit(LogsLoaded(
          logs: reversedLogs,
          currentFilter: event.topics,
        ));
      },
    );
  }

  Future<void> _onStartFollowingLogs(StartFollowingLogs event, Emitter<LogsState> emit) async {
    // Stop any existing subscription
    await _logsSubscription?.cancel();

    // شروع با لیست خالی - فقط لاگ‌های جدید نمایش داده می‌شوند
    emit(LogsFollowing(
      logs: <LogEntry>[],
      currentFilter: event.topics,
    ));

    // Create batched stream using buffer + periodic timer
    // Reduced to 100ms for faster response while still batching
    final logsStream = followLogsUseCase.call(topics: event.topics);
    final batchedStream = _batchLogStream(logsStream, const Duration(milliseconds: 100));

    // Use emit.forEach to properly handle stream emissions with batching
    await emit.forEach<List<Either<Failure, LogEntry>>>(
      batchedStream,
      onData: (batch) {
        if (state is! LogsFollowing) return state;
        
        final currentState = state as LogsFollowing;
        final newLogs = <LogEntry>[];
        
        // Process all items in batch
        for (final result in batch) {
          result.fold(
            (failure) => null, // Skip errors in batch
            (logEntry) => newLogs.add(logEntry),
          );
        }
        
        if (newLogs.isEmpty) return state;
        
        // اضافه همه لاگ‌های جدید به انتها (پایین)
        var updatedLogs = [...currentState.logs, ...newLogs];
        
        // محدود کردن به 500 لاگ (حذف قدیمی‌ترین از بالا)
        if (updatedLogs.length > 500) {
          updatedLogs = updatedLogs.sublist(updatedLogs.length - 500);
        }
        
        return LogsFollowing(
          logs: updatedLogs,
          currentFilter: currentState.currentFilter,
        );
      },
      onError: (error, stackTrace) {
        return const LogsError('Failed to follow logs');
      },
    );
  }

  // Helper method to batch stream items
  Stream<List<T>> _batchLogStream<T>(Stream<T> source, Duration duration) async* {
    final buffer = <T>[];
    Timer? debounceTimer;
    Timer? maxWaitTimer;
    final controller = StreamController<List<T>>();
    
    void emitBuffer() {
      debounceTimer?.cancel();
      maxWaitTimer?.cancel();
      if (buffer.isNotEmpty) {
        controller.add(List<T>.from(buffer));
        buffer.clear();
      }
    }
    
    source.listen(
      (item) {
        final isFirstItem = buffer.isEmpty;
        buffer.add(item);
        
        // Reset debounce timer on each new item
        debounceTimer?.cancel();
        debounceTimer = Timer(duration, emitBuffer);
        
        // Set max wait timer only for first item in batch
        // This ensures we emit even if items keep coming slowly
        if (isFirstItem) {
          maxWaitTimer = Timer(duration * 2, emitBuffer);
        }
      },
      onError: (error) => controller.addError(error),
      onDone: () {
        debounceTimer?.cancel();
        maxWaitTimer?.cancel();
        emitBuffer();
        controller.close();
      },
      cancelOnError: false,
    );
    
    yield* controller.stream;
  }

  Future<void> _onStopFollowingLogs(StopFollowingLogs event, Emitter<LogsState> emit) async {
    // Stop the stream from RouterOS
    followLogsUseCase.stop();
    
    // Cancel subscription
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
    // If following, stop it first before refreshing
    if (state is LogsFollowing) {
      followLogsUseCase.stop();
      await _logsSubscription?.cancel();
      _logsSubscription = null;
    }
    
    add(const LoadLogs());
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}