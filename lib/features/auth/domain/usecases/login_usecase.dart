import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/router_credentials.dart';
import '../entities/router_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, RouterSession>> call(RouterCredentials credentials) async {
    return await repository.login(credentials);
  }
}
