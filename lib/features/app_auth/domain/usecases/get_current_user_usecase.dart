import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/app_auth_repository.dart';

class GetCurrentUserUseCase {
  final AppAuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, AppUser?>> call() {
    return repository.getLoggedInUser();
  }
}
