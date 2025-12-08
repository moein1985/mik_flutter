import 'package:equatable/equatable.dart';

/// Base class for all Queues events
abstract class QueuesEvent extends Equatable {
  const QueuesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all queues
class LoadQueues extends QueuesEvent {
  const LoadQueues();
}

/// Event to add a new queue
class AddQueue extends QueuesEvent {
  final Map<String, dynamic> queueData;

  const AddQueue(this.queueData);

  @override
  List<Object?> get props => [queueData];
}

/// Event to update an existing queue
class UpdateQueue extends QueuesEvent {
  final String queueId;
  final Map<String, dynamic> queueData;

  const UpdateQueue(this.queueId, this.queueData);

  @override
  List<Object?> get props => [queueId, queueData];
}

/// Event to delete a queue
class DeleteQueue extends QueuesEvent {
  final String queueId;

  const DeleteQueue(this.queueId);

  @override
  List<Object?> get props => [queueId];
}

/// Event to toggle queue state (enable/disable)
class ToggleQueue extends QueuesEvent {
  final String queueId;
  final bool enable;

  const ToggleQueue(this.queueId, this.enable);

  @override
  List<Object?> get props => [queueId, enable];
}

/// Event to refresh queues list
class RefreshQueues extends QueuesEvent {
  const RefreshQueues();
}

/// Event to load a specific queue for editing
class LoadQueueForEdit extends QueuesEvent {
  final String queueId;

  const LoadQueueForEdit(this.queueId);

  @override
  List<Object?> get props => [queueId];
}