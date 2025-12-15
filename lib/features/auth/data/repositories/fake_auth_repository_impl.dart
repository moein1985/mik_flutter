import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/router_credentials.dart';
import '../../domain/entities/router_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Fake implementation of AuthRepository for development without a real router
/// 
/// This allows testing the entire app flow without connecting to a MikroTik device
class FakeAuthRepositoryImpl implements AuthRepository {
  RouterSession? _currentSession;
  RouterCredentials? _savedCredentials;
  
  @override
  Future<Either<Failure, RouterSession>> login(RouterCredentials credentials) async {
    await Future.delayed(AppConfig.fakeNetworkDelay);
    
    // Always succeed with any credentials in fake mode
    _currentSession = RouterSession(
      host: credentials.host,
      port: credentials.port,
      username: credentials.username,
      connectedAt: DateTime.now(),
    );
    
    return Right(_currentSession!);
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentSession = null;
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, RouterSession?>> getSavedSession() async {
    return Right(_currentSession);
  }
  
  @override
  Future<Either<Failure, void>> saveCredentials(RouterCredentials credentials) async {
    _savedCredentials = credentials;
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, RouterCredentials?>> getSavedCredentials() async {
    // Return some default credentials for easy testing
    return Right(_savedCredentials ?? const RouterCredentials(
      host: '192.168.88.1',
      port: 8728,
      username: 'admin',
      password: '',
    ));
  }
  
  @override
  Future<Either<Failure, void>> clearSavedCredentials() async {
    _savedCredentials = null;
    return const Right(null);
  }
}
