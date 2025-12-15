import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_router.dart';

sealed class SavedRouterState extends Equatable {
  const SavedRouterState();

  @override
  List<Object?> get props => [];
}

final class SavedRouterInitial extends SavedRouterState {
  const SavedRouterInitial();
}

final class SavedRouterLoading extends SavedRouterState {
  const SavedRouterLoading();
}

final class SavedRouterLoaded extends SavedRouterState {
  final List<SavedRouter> routers;

  const SavedRouterLoaded(this.routers);

  @override
  List<Object> get props => [routers];
}

final class SavedRouterOperationSuccess extends SavedRouterState {
  final String message;
  final List<SavedRouter>? routers;

  const SavedRouterOperationSuccess(this.message, {this.routers});

  @override
  List<Object?> get props => [message, routers];
}

final class SavedRouterError extends SavedRouterState {
  final String message;

  const SavedRouterError(this.message);

  @override
  List<Object> get props => [message];
}
