import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/monitoring/sentry_context_manager.dart';
import '../../../../core/network/routeros_client.dart';
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
  final RouterOSClient Function() getRouterClient;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.saveCredentialsUseCase,
    required this.getSavedCredentialsUseCase,
    required this.getRouterClient,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoadSavedCredentialsRequested>(_onLoadSavedCredentialsRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Tag router info to crash reports for better diagnostics
    Sentry.configureScope((scope) {
      scope.setTag('router_host', event.credentials.host);
      scope.setTag('router_port', event.credentials.port.toString());
      scope.setTag('router_use_ssl', event.credentials.useSsl.toString());
      scope.setContexts('login_attempt', {
        'username': event.credentials.username,
      });
    });

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
        
        // Fetch router system info for better crash context
        try {
          final client = getRouterClient();
          final resources = await client.getSystemResources();
          if (resources.isNotEmpty) {
            final resource = resources.first;
            SentryContextManager.setRouterContext(
              host: event.credentials.host,
              port: event.credentials.port,
              username: event.credentials.username,
              useSsl: event.credentials.useSsl,
              routerOsVersion: resource['version'],
              boardName: resource['board-name'],
              model: resource['platform'],
              uptime: resource['uptime'],
            );
          }
        } catch (e) {
          // If fetching router info fails, still set basic context
          SentryContextManager.setRouterContext(
            host: event.credentials.host,
            port: event.credentials.port,
            username: event.credentials.username,
            useSsl: event.credentials.useSsl,
          );
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
      (_) {
        // Clear router context from crash reports
        SentryContextManager.clearRouterContext();
        emit(const AuthUnauthenticated());
      },
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
