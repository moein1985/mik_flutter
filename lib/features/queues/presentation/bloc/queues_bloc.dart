import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_queue_usecase.dart';
import '../../domain/usecases/delete_queue_usecase.dart';
import '../../domain/usecases/edit_queue_usecase.dart';
import '../../domain/usecases/get_queues_usecase.dart';
import '../../domain/usecases/get_queue_by_id_usecase.dart';
import '../../domain/usecases/toggle_queue_usecase.dart';
import 'queues_event.dart';
import 'queues_state.dart';

class QueuesBloc extends Bloc<QueuesEvent, QueuesState> {
  final GetQueuesUseCase getQueuesUseCase;
  final GetQueueByIdUseCase getQueueByIdUseCase;
  final AddQueueUseCase addQueueUseCase;
  final EditQueueUseCase editQueueUseCase;
  final DeleteQueueUseCase deleteQueueUseCase;
  final ToggleQueueUseCase toggleQueueUseCase;

  QueuesBloc({
    required this.getQueuesUseCase,
    required this.getQueueByIdUseCase,
    required this.addQueueUseCase,
    required this.editQueueUseCase,
    required this.deleteQueueUseCase,
    required this.toggleQueueUseCase,
  }) : super(const QueuesInitial()) {
    on<LoadQueues>(_onLoadQueues);
    on<LoadQueueForEdit>(_onLoadQueueForEdit);
    on<AddQueue>(_onAddQueue);
    on<UpdateQueue>(_onUpdateQueue);
    on<DeleteQueue>(_onDeleteQueue);
    on<ToggleQueue>(_onToggleQueue);
    on<RefreshQueues>(_onRefreshQueues);
  }

  Future<void> _onLoadQueues(LoadQueues event, Emitter<QueuesState> emit) async {
    emit(const QueuesLoading());

    final result = await getQueuesUseCase.call();

    result.fold(
      (failure) => emit(QueuesError(failure.message)),
      (queues) => emit(QueuesLoaded(queues)),
    );
  }

  Future<void> _onLoadQueueForEdit(LoadQueueForEdit event, Emitter<QueuesState> emit) async {
    emit(const QueuesLoading());

    final result = await getQueueByIdUseCase.call(event.queueId);

    result.fold(
      (failure) => emit(QueuesError(failure.message)),
      (queue) => emit(QueueLoadedForEdit(queue)),
    );
  }

  Future<void> _onAddQueue(AddQueue event, Emitter<QueuesState> emit) async {
    emit(const AddingQueue());

    final result = await addQueueUseCase.call(event.queueData);

    result.fold(
      (failure) => emit(QueuesError(failure.message)),
      (_) {
        emit(const QueueOperationSuccess('Queue added successfully'));
        // Reload queues to show the new queue
        add(const LoadQueues());
      },
    );
  }

  Future<void> _onUpdateQueue(UpdateQueue event, Emitter<QueuesState> emit) async {
    emit(const UpdatingQueue());

    final result = await editQueueUseCase.call(event.queueId, event.queueData);

    result.fold(
      (failure) => emit(QueuesError(failure.message)),
      (_) {
        emit(const QueueOperationSuccess('Queue updated successfully'));
        // Reload queues to show the updated queue
        add(const LoadQueues());
      },
    );
  }

  Future<void> _onDeleteQueue(DeleteQueue event, Emitter<QueuesState> emit) async {
    emit(const DeletingQueue());

    final result = await deleteQueueUseCase.call(event.queueId);

    result.fold(
      (failure) => emit(QueuesError(failure.message)),
      (_) {
        emit(const QueueOperationSuccess('Queue deleted successfully'));
        // Reload queues to remove the deleted queue
        add(const LoadQueues());
      },
    );
  }

  Future<void> _onToggleQueue(ToggleQueue event, Emitter<QueuesState> emit) async {
    emit(const QueueOperationInProgress());

    final result = await toggleQueueUseCase.call(event.queueId, event.enable);

    result.fold(
      (failure) => emit(QueuesError(failure.message)),
      (_) {
        final message = event.enable ? 'Queue enabled successfully' : 'Queue disabled successfully';
        emit(QueueOperationSuccess(message));
        // Reload queues to show the updated status
        add(const LoadQueues());
      },
    );
  }

  Future<void> _onRefreshQueues(RefreshQueues event, Emitter<QueuesState> emit) async {
    // Just reload the queues
    add(const LoadQueues());
  }
}