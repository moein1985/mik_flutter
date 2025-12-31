import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_agent_details_usecase.dart';
import '../../domain/usecases/pause_agent_usecase.dart';
import '../../domain/usecases/unpause_agent_usecase.dart';
import '../../core/result.dart';
import 'agent_detail_event.dart';
import 'agent_detail_state.dart';

class AgentDetailBloc extends Bloc<AgentDetailEvent, AgentDetailState> {
  final GetAgentDetailsUseCase getAgentDetailsUseCase;
  final PauseAgentUseCase pauseAgentUseCase;
  final UnpauseAgentUseCase unpauseAgentUseCase;

  AgentDetailBloc({
    required this.getAgentDetailsUseCase,
    required this.pauseAgentUseCase,
    required this.unpauseAgentUseCase,
  }) : super(AgentDetailInitial()) {
    on<LoadAgentDetails>((event, emit) async {
      emit(AgentDetailLoading());
      final result = await getAgentDetailsUseCase(event.agentInterface);
      switch (result) {
        case Success(:final data):
          final details = data;
          emit(AgentDetailLoaded(details));
        case Failure(:final message):
          emit(AgentDetailError(message));
      }
    });

    on<PauseAgentFromDetail>((event, emit) async {
      if (state is AgentDetailLoaded) {
        final currentDetails = (state as AgentDetailLoaded).details;
        final result = await pauseAgentUseCase(
          queue: event.queue,
          interface: event.interface,
          reason: event.reason,
        );
        switch (result) {
          case Success():
            // Reload details
            add(LoadAgentDetails(event.interface));
          case Failure(:final message):
            emit(AgentDetailError(message));
            // Restore previous state
            emit(AgentDetailLoaded(currentDetails));
        }
      }
    });

    on<UnpauseAgentFromDetail>((event, emit) async {
      if (state is AgentDetailLoaded) {
        final currentDetails = (state as AgentDetailLoaded).details;
        final result = await unpauseAgentUseCase(
          queue: event.queue,
          interface: event.interface,
        );
        switch (result) {
          case Success():
            // Reload details
            add(LoadAgentDetails(event.interface));
          case Failure(:final message):
            emit(AgentDetailError(message));
            // Restore previous state
            emit(AgentDetailLoaded(currentDetails));
        }
      }
    });
  }
}
