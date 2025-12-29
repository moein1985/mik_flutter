import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/app_auth_repository.dart';

class ChangePasswordUseCase {
  final AppAuthRepository repository;
  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String oldPassword, String newPassword) {
    return repository.changePassword(userId, oldPassword, newPassword);
  }
}
