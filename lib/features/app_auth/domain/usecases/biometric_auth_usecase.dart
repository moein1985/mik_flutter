import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/app_auth_repository.dart';

class BiometricAuthUseCase {
  final AppAuthRepository repository;

  BiometricAuthUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.authenticateWithBiometric();
  }

  Future<Either<Failure, bool>> canAuthenticate() {
    return repository.canAuthenticateWithBiometric();
  }

  Future<Either<Failure, void>> enable(String userId) {
    return repository.enableBiometric(userId);
  }

  Future<Either<Failure, void>> disable(String userId) {
    return repository.disableBiometric(userId);
  }
}
