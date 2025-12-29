import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/app_auth_repository.dart';

class LoginUseCase {
  final AppAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AppUser>> call(String username, String password) {
    return repository.login(username, password);
  }
}
