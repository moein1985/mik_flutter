import 'package:equatable/equatable.dart';

abstract class SavedRouterEvent extends Equatable {
  const SavedRouterEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedRouters extends SavedRouterEvent {
  const LoadSavedRouters();
}

class SaveRouter extends SavedRouterEvent {
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isDefault;

  const SaveRouter({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [name, host, port, username, password, isDefault];
}

class DeleteSavedRouter extends SavedRouterEvent {
  final int id;

  const DeleteSavedRouter(this.id);

  @override
  List<Object> get props => [id];
}

class SetDefaultSavedRouter extends SavedRouterEvent {
  final int id;

  const SetDefaultSavedRouter(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateSavedRouter extends SavedRouterEvent {
  final int id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isDefault;

  const UpdateSavedRouter({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, name, host, port, username, password, isDefault];
}
