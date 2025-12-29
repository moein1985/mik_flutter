import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/app_auth_repository.dart';

class RegisterUseCase {
  final AppAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AppUser>> call(String username, String password) {
    return repository.register(username, password);
  }
}
