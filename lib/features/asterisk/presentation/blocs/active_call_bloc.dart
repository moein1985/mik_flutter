import 'package:bloc/bloc.dart';
import '../../core/result.dart';
import '../../domain/usecases/get_active_calls_usecase.dart';
import '../../domain/usecases/hangup_call_usecase.dart';
import '../../domain/usecases/transfer_call_usecase.dart';
import 'active_call_event.dart';
import 'active_call_state.dart';

class ActiveCallBloc extends Bloc<ActiveCallEvent, ActiveCallState> {
  final GetActiveCallsUseCase getActiveCallsUseCase;
  final HangupCallUseCase hangupCallUseCase;
  final TransferCallUseCase transferCallUseCase;

  ActiveCallBloc(
    this.getActiveCallsUseCase,
    this.hangupCallUseCase,
    this.transferCallUseCase,
  ) : super(const ActiveCallInitial()) {
    on<LoadActiveCalls>((event, emit) async {
      emit(const ActiveCallLoading());
      final result = await getActiveCallsUseCase();
      switch (result) {
        case Success(:final data):
          emit(ActiveCallLoaded(data));
        case Failure(:final message):
          emit(ActiveCallError(message));
      }
    });

    on<HangupCall>((event, emit) async {
      emit(const ActiveCallLoading());
      final hangupResult = await hangupCallUseCase(event.channel);
      switch (hangupResult) {
        case Success():
          final callsResult = await getActiveCallsUseCase();
          switch (callsResult) {
            case Success(:final data):
              emit(ActiveCallLoaded(data));
            case Failure(:final message):
              emit(ActiveCallError(message));
          }
        case Failure(:final message):
          emit(ActiveCallError(message));
      }
    });

    on<TransferCall>((event, emit) async {
      emit(const ActiveCallLoading());
      final transferResult = await transferCallUseCase(
        channel: event.channel,
        destination: event.destination,
        context: event.context,
      );
      switch (transferResult) {
        case Success():
          final callsResult = await getActiveCallsUseCase();
          switch (callsResult) {
            case Success(:final data):
              emit(ActiveCallLoaded(data));
            case Failure(:final message):
              emit(ActiveCallError(message));
          }
        case Failure(:final message):
          emit(ActiveCallError(message));
      }
    });
  }
}
