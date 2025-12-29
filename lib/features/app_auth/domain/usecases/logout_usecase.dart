import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/app_auth_repository.dart';

class LogoutUseCase {
  final AppAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
