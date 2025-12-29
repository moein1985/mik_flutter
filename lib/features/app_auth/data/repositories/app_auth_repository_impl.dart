import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/app_auth_repository.dart';
import '../datasources/app_auth_local_datasource.dart';

final _log = AppLogger.tag('AppAuthRepository');

class AppAuthRepositoryImpl implements AppAuthRepository {
  final AppAuthLocalDataSource localDataSource;
  final LocalAuthentication localAuth;

  AppAuthRepositoryImpl({
    required this.localDataSource,
    required this.localAuth,
  });

  @override
  Future<Either<Failure, AppUser?>> getLoggedInUser() async {
    try {
      _log.i('getLoggedInUser: calling localDataSource');
      final user = await localDataSource.getLoggedInUser();
      _log.i('getLoggedInUser: localDataSource returned user=${user != null}');
      return Right(user);
    } catch (e) {
      _log.e('getLoggedInUser failed: $e');
      return Left(CacheFailure('Failed to get logged in user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> login(String username, String password) async {
    try {
      final user = await localDataSource.login(username, password);
      if (user == null) {
        return Left(AuthenticationFailure('Invalid username or password'));
      }
      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register(String username, String password) async {
    try {
      final user = await localDataSource.register(username, password);
      return Right(user);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> canAuthenticateWithBiometric() async {
    try {
      final canCheck = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      return Right(canCheck && isDeviceSupported);
    } catch (e) {
      return Left(ServerFailure('Failed to check biometric availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    try {
      _log.i('Attempting biometric authentication (repo)');
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      _log.i('Biometric auth result (repo): $authenticated');
      return Right(authenticated);
    } catch (e, st) {
      _log.e('Biometric authentication failed (repo): $e', error: e, stackTrace: st);
      return Left(AuthenticationFailure('Biometric authentication failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> enableBiometric(String userId) async {
    try {
      _log.i('Enabling biometric for user: $userId');
      await localDataSource.updateBiometricStatus(userId, true);
      _log.i('Enabled biometric for user: $userId');
      return const Right(null);
    } catch (e, st) {
      _log.e('Failed to enable biometric for $userId: $e', error: e, stackTrace: st);
      return Left(CacheFailure('Failed to enable biometric: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> disableBiometric(String userId) async {
    try {
      _log.i('Disabling biometric for user: $userId');
      await localDataSource.updateBiometricStatus(userId, false);
      _log.i('Disabled biometric for user: $userId');
      return const Right(null);
    } catch (e, st) {
      _log.e('Failed to disable biometric for $userId: $e', error: e, stackTrace: st);
      return Left(CacheFailure('Failed to disable biometric: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      await localDataSource.changePassword(userId, oldPassword, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to change password: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasBiometricEnabledUsers() async {
    try {
      _log.i('Checking for any biometric-enabled users');
      final exists = await localDataSource.hasBiometricEnabledUsers();
      _log.i('hasBiometricEnabledUsers: $exists');
      return Right(exists);
    } catch (e, st) {
      _log.e('Failed to check biometric-enabled users: $e', error: e, stackTrace: st);
      return Left(CacheFailure('Failed to check biometric-enabled users: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getBiometricUser() async {
    try {
      _log.i('Fetching biometric-enabled user');
      final user = await localDataSource.getUserByBiometric();
      _log.i('getBiometricUser: found=${user != null}');
      return Right(user);
    } catch (e, st) {
      _log.e('Failed to get biometric user: $e', error: e, stackTrace: st);
      return Left(CacheFailure('Failed to get biometric user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> setLoggedInUserById(String userId) async {
    try {
      _log.i('Setting logged in user: $userId');
      await localDataSource.setLoggedInUser(userId);
      _log.i('Session set for user: $userId');
      return const Right(null);
    } catch (e, st) {
      _log.e('Failed to set logged in user: $e', error: e, stackTrace: st);
      return Left(CacheFailure('Failed to set logged in user: ${e.toString()}'));
    }
  }
}
