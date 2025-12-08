import 'package:equatable/equatable.dart';
import '../../domain/entities/simple_queue.dart';

/// Base class for all Queues states
abstract class QueuesState extends Equatable {
  const QueuesState();

  @override
  List<Object?> get props => [];
}

/// Initial state when Queues page is first loaded
class QueuesInitial extends QueuesState {
  const QueuesInitial();
}

/// State when queues are being loaded
class QueuesLoading extends QueuesState {
  const QueuesLoading();
}

/// State when queues are loaded successfully
class QueuesLoaded extends QueuesState {
  final List<SimpleQueue> queues;

  const QueuesLoaded(this.queues);

  @override
  List<Object?> get props => [queues];
}

/// State when queue operation is in progress
class QueueOperationInProgress extends QueuesState {
  const QueueOperationInProgress();
}

/// State when queue operation completed successfully
class QueueOperationSuccess extends QueuesState {
  final String message;

  const QueueOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when queue operation failed
class QueuesError extends QueuesState {
  final String error;

  const QueuesError(this.error);

  @override
  List<Object?> get props => [error];
}

/// State when adding a new queue
class AddingQueue extends QueuesState {
  const AddingQueue();
}

/// State when updating a queue
class UpdatingQueue extends QueuesState {
  const UpdatingQueue();
}

/// State when deleting a queue
class DeletingQueue extends QueuesState {
  const DeletingQueue();
}

/// State when a queue is loaded for editing
class QueueLoadedForEdit extends QueuesState {
  final SimpleQueue queue;

  const QueueLoadedForEdit(this.queue);

  @override
  List<Object?> get props => [queue];
}