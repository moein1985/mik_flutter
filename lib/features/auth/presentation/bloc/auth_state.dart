import 'package:equatable/equatable.dart';
import '../../domain/entities/router_credentials.dart';
import '../../domain/entities/router_session.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final RouterSession session;

  const AuthAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

class AuthUnauthenticated extends AuthState {
  final RouterCredentials? savedCredentials;

  const AuthUnauthenticated({this.savedCredentials});

  @override
  List<Object?> get props => [savedCredentials];
}

class AuthError extends AuthState {
  final String message;
  final bool isSslCertificateError;

  const AuthError(this.message, {this.isSslCertificateError = false});

  @override
  List<Object?> get props => [message, isSslCertificateError];
}
