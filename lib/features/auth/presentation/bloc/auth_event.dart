import 'package:equatable/equatable.dart';
import '../../domain/entities/router_credentials.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final RouterCredentials credentials;
  final bool rememberMe;

  const LoginRequested({
    required this.credentials,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [credentials, rememberMe];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckSavedSessionRequested extends AuthEvent {
  const CheckSavedSessionRequested();
}

class LoadSavedCredentialsRequested extends AuthEvent {
  const LoadSavedCredentialsRequested();
}
