import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/biometric_auth_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/has_biometric_enabled_users_usecase.dart';
import '../../domain/usecases/get_biometric_user_usecase.dart';
import '../../domain/usecases/set_logged_in_user_usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'app_auth_event.dart';
import 'app_auth_state.dart';

final _log = AppLogger.tag('AppAuthBloc');

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
    _log.i('CheckAuthStatus received');
    emit(const AppAuthLoading());

    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        _log.i('CheckAuthStatus result: failure -> unauthenticated: ${failure.message}');
        emit(const AppAuthUnauthenticated());
      },
      (user) {
        _log.i('CheckAuthStatus result: user found = ${user != null}');
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
    await userResult.fold(
      (failure) async => emit(AppAuthError(failure.message)),
      (user) async {
        if (user == null) {
          _log.i('Biometric login requested but no session user found');

          // Check if any user has biometric enabled (diagnostic)
          try {
            final hasResult = await sl<HasBiometricEnabledUsersUseCase>()();
            await hasResult.fold((failure) async {
              _log.e('Failed to check biometric-enabled users: ${failure.message}');
              emit(AppAuthError(failure.message));
            }, (hasAny) async {
              _log.i('Has biometric-enabled users: $hasAny');
              if (!hasAny) {
                emit(const AppAuthError('Biometric authentication not enabled'));
                return;
              }

              // Try to find a biometric-enabled user and sign in
              final userResult = await sl<GetBiometricUserUseCase>()();
              await userResult.fold((failure) async {
                _log.e('Failed to get biometric user: ${failure.message}');
                emit(AppAuthError(failure.message));
              }, (biometricUser) async {
                if (biometricUser == null) {
                  _log.i('No biometric-enabled user found despite hasAny=true');
                  emit(const AppAuthError('Biometric authentication not enabled'));
                  return;
                }

                _log.i('Found biometric user: ${biometricUser.id}, starting biometric authentication');
                final authResult = await biometricAuthUseCase();
                await authResult.fold((failure) async => emit(AppAuthError(failure.message)), (authenticated) async {
                  if (!authenticated) {
                    emit(const AppAuthError('Biometric authentication failed'));
                    return;
                  }

                  // Set session and emit authenticated (with verification + diagnostic logs)
                  final setResult = await sl<SetLoggedInUserUseCase>()(biometricUser.id);
                  await setResult.fold((failure) async {
                    _log.e('Failed to set session for biometric user: ${failure.message}');
                    emit(AppAuthError(failure.message));
                  }, (_) async {
                    try {
                      _log.i('Session created for biometric user: ${biometricUser.id}');

                      // Verify session is visible to the repository
                      String? verifiedId;
                      final verifyRes = await getCurrentUserUseCase();
                      verifyRes.fold(
                        (f) => _log.e('getCurrentUserUseCase failed after set: ${f.message}'),
                        (verifiedUser) {
                          verifiedId = verifiedUser?.id;
                          _log.i('getCurrentUserUseCase returned after set: ${verifiedUser?.id}');
                        },
                      );

                      // Emit authenticated (use biometricUser as fallback)
                      emit(AppAuthAuthenticated(biometricUser));
                      _log.i('Emitted AppAuthAuthenticated for user=${biometricUser.id}, verifiedId=$verifiedId, current state=${state.runtimeType}');
                    } catch (e, st) {
                      _log.e('Exception while emitting authenticated state: $e', error: e, stackTrace: st);
                      emit(AppAuthError(e.toString()));
                    }
                  });
                });
              });
            });
          } catch (e, st) {
            _log.e('Exception while checking biometric-enabled users: $e', error: e, stackTrace: st);
            emit(AppAuthError(e.toString()));
          }

          return;
        }

        if (!user.biometricEnabled) {
          _log.i('Current session user has biometric disabled: ${user.id}');
          emit(const AppAuthError('Biometric authentication not enabled'));
          return;
        }

        // Authenticate
        final authResult = await biometricAuthUseCase();
        await authResult.fold(
          (failure) async => emit(AppAuthError(failure.message)),
          (authenticated) async {
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

    _log.i('BiometricToggleRequested received: enable=${event.enable} for user=${currentState.user.id}');

    final result = event.enable
        ? await biometricAuthUseCase.enable(currentState.user.id)
        : await biometricAuthUseCase.disable(currentState.user.id);

    result.fold(
      (failure) {
        _log.e('Biometric toggle failed for user=${currentState.user.id}: ${failure.message}');
        emit(AppAuthError(failure.message));
      },
      (_) {
        _log.i('Biometric toggle succeeded for user=${currentState.user.id}: enable=${event.enable}');
        final updatedUser = currentState.user.copyWith(
          biometricEnabled: event.enable,
        );
        emit(AppAuthAuthenticated(updatedUser));
      },
    );
  }
}
