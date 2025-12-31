import 'package:bloc/bloc.dart';
import '../../core/result.dart';
import '../../domain/usecases/get_queue_status_usecase.dart';
import '../../domain/usecases/pause_agent_usecase.dart';
import '../../domain/usecases/unpause_agent_usecase.dart';
import 'queue_event.dart';
import 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueStatusUseCase getQueueStatusUseCase;
  final PauseAgentUseCase pauseAgentUseCase;
  final UnpauseAgentUseCase unpauseAgentUseCase;

  QueueBloc({
    required this.getQueueStatusUseCase,
    required this.pauseAgentUseCase,
    required this.unpauseAgentUseCase,
  }) : super(const QueueInitial()) {
    on<LoadQueues>((event, emit) async {
      emit(const QueueLoading());
      final result = await getQueueStatusUseCase();
      switch (result) {
        case Success(:final data):
          final queues = data;
          emit(QueueLoaded(queues));
        case Failure(:final message):
          emit(QueueError(message));
      }
    });

    on<PauseAgent>((event, emit) async {
      final result = await pauseAgentUseCase(
        queue: event.queue,
        interface: event.interface,
        reason: event.reason,
      );
      switch (result) {
        case Success():
          // Reload queues to refresh the UI
          add(const LoadQueues());
        case Failure(:final message):
          emit(QueueError(message));
      }
    });

    on<UnpauseAgent>((event, emit) async {
      final result = await unpauseAgentUseCase(
        queue: event.queue,
        interface: event.interface,
      );
      switch (result) {
        case Success():
          // Reload queues to refresh the UI
          add(const LoadQueues());
        case Failure(:final message):
          emit(QueueError(message));
      }
    });
  }
}
