import 'package:equatable/equatable.dart';

abstract class AppAuthEvent extends Equatable {
  const AppAuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AppAuthEvent {
  const CheckAuthStatus();
}

class LoginRequested extends AppAuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class RegisterRequested extends AppAuthEvent {
  final String username;
  final String password;

  const RegisterRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class BiometricLoginRequested extends AppAuthEvent {
  const BiometricLoginRequested();
}

class LogoutRequested extends AppAuthEvent {
  const LogoutRequested();
}

class BiometricToggleRequested extends AppAuthEvent {
  final bool enable;

  const BiometricToggleRequested(this.enable);

  @override
  List<Object?> get props => [enable];
}
