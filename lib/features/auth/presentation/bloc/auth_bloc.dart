import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_saved_credentials_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/save_credentials_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final SaveCredentialsUseCase saveCredentialsUseCase;
  final GetSavedCredentialsUseCase getSavedCredentialsUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.saveCredentialsUseCase,
    required this.getSavedCredentialsUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoadSavedCredentialsRequested>(_onLoadSavedCredentialsRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(event.credentials);

    await result.fold(
      (failure) async {
        // Check if it's an SSL certificate error
        final isSslError = failure is SslCertificateFailure;
        emit(AuthError(failure.message, isSslCertificateError: isSslError));
      },
      (session) async {
        if (event.rememberMe) {
          await saveCredentialsUseCase(event.credentials);
        }
        if (!emit.isDone) {
          emit(AuthAuthenticated(session));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLoadSavedCredentialsRequested(
    LoadSavedCredentialsRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getSavedCredentialsUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (credentials) => emit(AuthUnauthenticated(savedCredentials: credentials)),
    );
  }
}
