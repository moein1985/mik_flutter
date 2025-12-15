import 'package:equatable/equatable.dart';
import '../../domain/entities/simple_queue.dart';

/// Sealed class for all Queues states with exhaustive matching
sealed class QueuesState extends Equatable {
  const QueuesState();

  @override
  List<Object?> get props => [];
}

/// Initial state when Queues page is first loaded
final class QueuesInitial extends QueuesState {
  const QueuesInitial();
}

/// State when queues are being loaded
final class QueuesLoading extends QueuesState {
  const QueuesLoading();
}

/// State when queues are loaded successfully (non-nullable!)
final class QueuesLoaded extends QueuesState {
  final List<SimpleQueue> queues;

  const QueuesLoaded(this.queues);

  @override
  List<Object?> get props => [queues];
}

/// State when queue operation is in progress
final class QueueOperationInProgress extends QueuesState {
  const QueueOperationInProgress();
}

/// State when queue operation completed successfully
final class QueueOperationSuccess extends QueuesState {
  final String message;

  const QueueOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when queue operation failed
final class QueuesError extends QueuesState {
  final String error;

  const QueuesError(this.error);

  @override
  List<Object?> get props => [error];
}

/// State when a queue is loaded for editing
final class QueueLoadedForEdit extends QueuesState {
  final SimpleQueue queue;

  const QueueLoadedForEdit(this.queue);

  @override
  List<Object?> get props => [queue];
}