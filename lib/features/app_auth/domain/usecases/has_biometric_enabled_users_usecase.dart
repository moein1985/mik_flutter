import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/app_auth_repository.dart';

class HasBiometricEnabledUsersUseCase {
  final AppAuthRepository repository;

  HasBiometricEnabledUsersUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.hasBiometricEnabledUsers();
  }
}