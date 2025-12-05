import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/router_credentials.dart';
import '../../domain/entities/router_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/router_credentials_model.dart';
import '../models/router_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, RouterSession>> login(RouterCredentials credentials) async {
    try {
      await remoteDataSource.login(
        credentials.host,
        credentials.port,
        credentials.username,
        credentials.password,
        useSsl: credentials.useSsl,
      );

      final session = RouterSessionModel(
        host: credentials.host,
        port: credentials.port,
        username: credentials.username,
        connectedAt: DateTime.now(),
        useSsl: credentials.useSsl,
      );

      await localDataSource.saveSession(session);

      return Right(session);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on SslCertificateException catch (e) {
      return Left(SslCertificateFailure(e.message, noCertificate: e.noCertificate));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.disconnect();
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, RouterSession?>> getSavedSession() async {
    try {
      final session = await localDataSource.getSavedSession();
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveCredentials(RouterCredentials credentials) async {
    try {
      final model = RouterCredentialsModel.fromEntity(credentials);
      await localDataSource.saveCredentials(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RouterCredentials?>> getSavedCredentials() async {
    try {
      final credentials = await localDataSource.getSavedCredentials();
      return Right(credentials);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearSavedCredentials() async {
    try {
      await localDataSource.clearCredentials();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
