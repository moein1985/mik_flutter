import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/app_auth_repository.dart';
import '../../domain/entities/app_user.dart';

class GetBiometricUserUseCase {
  final AppAuthRepository repository;

  GetBiometricUserUseCase(this.repository);

  Future<Either<Failure, AppUser?>> call() {
    return repository.getBiometricUser();
  }
}