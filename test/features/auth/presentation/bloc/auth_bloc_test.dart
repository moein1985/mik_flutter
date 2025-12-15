import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hsmik/features/auth/presentation/bloc/auth_event.dart';
import 'package:hsmik/features/auth/presentation/bloc/auth_state.dart';
import 'package:hsmik/features/auth/domain/entities/router_credentials.dart';
import 'package:hsmik/features/auth/domain/entities/router_session.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/auth_mocks.dart';

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockSaveCredentialsUseCase mockSaveCredentialsUseCase;
  late MockGetSavedCredentialsUseCase mockGetSavedCredentialsUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockSaveCredentialsUseCase = MockSaveCredentialsUseCase();
    mockGetSavedCredentialsUseCase = MockGetSavedCredentialsUseCase();

    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      saveCredentialsUseCase: mockSaveCredentialsUseCase,
      getSavedCredentialsUseCase: mockGetSavedCredentialsUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(const RouterCredentials(
      host: '192.168.1.1',
      port: 8728,
      username: 'admin',
      password: '',
    ));
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(bloc.state, const AuthInitial());
    });

    group('LoginRequested', () {
      final tCredentials = const RouterCredentials(
        host: '192.168.1.1',
        port: 8728,
        username: 'admin',
        password: 'password123',
      );

      final tSession = RouterSession(
        host: '192.168.1.1',
        port: 8728,
        username: 'admin',
        connectedAt: DateTime.now(),
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when login successful',
        build: () {
          when(() => mockLoginUseCase(tCredentials))
              .thenAnswer((_) async => Right(tSession));
          return bloc;
        },
        act: (bloc) => bloc.add(LoginRequested(credentials: tCredentials)),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tSession),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase(tCredentials)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should save credentials when rememberMe is true',
        build: () {
          when(() => mockLoginUseCase(tCredentials))
              .thenAnswer((_) async => Right(tSession));
          when(() => mockSaveCredentialsUseCase(tCredentials))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(
          LoginRequested(
            credentials: tCredentials,
            rememberMe: true,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tSession),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase(tCredentials)).called(1);
          verify(() => mockSaveCredentialsUseCase(tCredentials)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when login fails',
        build: () {
          when(() => mockLoginUseCase(tCredentials))
              .thenAnswer((_) async => const Left(ServerFailure('Invalid credentials')));
          return bloc;
        },
        act: (bloc) => bloc.add(LoginRequested(credentials: tCredentials)),
        expect: () => [
          const AuthLoading(),
          const AuthError('Invalid credentials'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit AuthError with SSL flag on certificate failure',
        build: () {
          when(() => mockLoginUseCase(tCredentials))
              .thenAnswer((_) async => const Left(SslCertificateFailure('Certificate error')));
          return bloc;
        },
        act: (bloc) => bloc.add(LoginRequested(credentials: tCredentials)),
        expect: () => [
          const AuthLoading(),
          const AuthError('Certificate error', isSslCertificateError: true),
        ],
      );
    });

    group('LogoutRequested', () {
      final tSession = RouterSession(
        host: '192.168.1.1',
        port: 8728,
        username: 'admin',
        connectedAt: DateTime.now(),
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when logout successful',
        build: () {
          when(() => mockLogoutUseCase())
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => AuthAuthenticated(tSession),
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockLogoutUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when logout fails',
        build: () {
          when(() => mockLogoutUseCase())
              .thenAnswer((_) async => const Left(ServerFailure('Logout failed')));
          return bloc;
        },
        seed: () => AuthAuthenticated(tSession),
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError('Logout failed'),
        ],
      );
    });

    group('LoadSavedCredentialsRequested', () {
      final tCredentials = const RouterCredentials(
        host: '192.168.1.1',
        port: 8728,
        username: 'admin',
        password: 'saved_password',
      );

      blocTest<AuthBloc, AuthState>(
        'should emit AuthUnauthenticated with saved credentials',
        build: () {
          when(() => mockGetSavedCredentialsUseCase())
              .thenAnswer((_) async => Right(tCredentials));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSavedCredentialsRequested()),
        expect: () => [
          AuthUnauthenticated(savedCredentials: tCredentials),
        ],
        verify: (_) {
          verify(() => mockGetSavedCredentialsUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit AuthUnauthenticated with null when no credentials saved',
        build: () {
          when(() => mockGetSavedCredentialsUseCase())
              .thenAnswer((_) async => const Left(CacheFailure('No saved credentials')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSavedCredentialsRequested()),
        expect: () => [
          const AuthUnauthenticated(savedCredentials: null),
        ],
      );
    });
  });
}
