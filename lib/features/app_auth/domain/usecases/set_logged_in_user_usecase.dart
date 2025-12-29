import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/app_auth_repository.dart';

class SetLoggedInUserUseCase {
  final AppAuthRepository repository;

  SetLoggedInUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.setLoggedInUserById(userId);
  }
}