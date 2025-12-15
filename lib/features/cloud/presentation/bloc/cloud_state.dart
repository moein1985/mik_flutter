import 'package:equatable/equatable.dart';
import '../../domain/entities/cloud_status.dart';

sealed class CloudState extends Equatable {
  const CloudState();

  @override
  List<Object?> get props => [];
}

final class CloudInitial extends CloudState {
  const CloudInitial();
}

final class CloudLoading extends CloudState {
  const CloudLoading();
}

final class CloudLoaded extends CloudState {
  final CloudStatus status;

  const CloudLoaded(this.status);

  @override
  List<Object> get props => [status];
}

final class CloudError extends CloudState {
  final String message;

  const CloudError(this.message);

  @override
  List<Object> get props => [message];
}

final class CloudOperationSuccess extends CloudState {
  final String message;
  final CloudStatus? previousStatus;

  const CloudOperationSuccess(this.message, {this.previousStatus});

  @override
  List<Object?> get props => [message, previousStatus];
}

final class CloudOperationInProgress extends CloudState {
  final String operation;
  final CloudStatus? currentStatus;

  const CloudOperationInProgress(this.operation, {this.currentStatus});

  @override
  List<Object?> get props => [operation, currentStatus];
}
