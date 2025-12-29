import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/biometric_auth_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'app_auth_event.dart';
import 'app_auth_state.dart';

class AppAuthBloc extends Bloc<AppAuthEvent, AppAuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final BiometricAuthUseCase biometricAuthUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AppAuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.biometricAuthUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AppAuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BiometricToggleRequested>(_onBiometricToggleRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(const AppAuthLoading());

    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(const AppAuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AppAuthAuthenticated(user));
        } else {
          emit(const AppAuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(const AppAuthLoading());

    final result = await loginUseCase(event.username, event.password);
    result.fold(
      (failure) => emit(AppAuthError(failure.message)),
      (user) => emit(AppAuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(const AppAuthLoading());

    final result = await registerUseCase(event.username, event.password);
    result.fold(
      (failure) => emit(AppAuthError(failure.message)),
      (user) => emit(AppAuthAuthenticated(user)),
    );
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(const AppAuthLoading());

    // Check if user has biometric enabled
    final userResult = await getCurrentUserUseCase();
    userResult.fold(
      (failure) => emit(AppAuthError(failure.message)),
      (user) async {
        if (user == null || !user.biometricEnabled) {
          emit(const AppAuthError('Biometric authentication not enabled'));
          return;
        }

        // Authenticate
        final authResult = await biometricAuthUseCase();
        authResult.fold(
          (failure) => emit(AppAuthError(failure.message)),
          (authenticated) {
            if (authenticated) {
              emit(AppAuthAuthenticated(user));
            } else {
              emit(const AppAuthError('Biometric authentication failed'));
            }
          },
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    await logoutUseCase();
    emit(const AppAuthUnauthenticated());
  }

  Future<void> _onBiometricToggleRequested(
    BiometricToggleRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppAuthAuthenticated) return;

    final result = event.enable
        ? await biometricAuthUseCase.enable(currentState.user.id)
        : await biometricAuthUseCase.disable(currentState.user.id);

    result.fold(
      (failure) => emit(AppAuthError(failure.message)),
      (_) {
        final updatedUser = currentState.user.copyWith(
          biometricEnabled: event.enable,
        );
        emit(AppAuthAuthenticated(updatedUser));
      },
    );
  }
}
