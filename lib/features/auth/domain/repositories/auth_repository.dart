import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/router_credentials.dart';
import '../entities/router_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, RouterSession>> login(RouterCredentials credentials);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, RouterSession?>> getSavedSession();
  Future<Either<Failure, void>> saveCredentials(RouterCredentials credentials);
  Future<Either<Failure, RouterCredentials?>> getSavedCredentials();
  Future<Either<Failure, void>> clearSavedCredentials();
}
