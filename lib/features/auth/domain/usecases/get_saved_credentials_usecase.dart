import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/router_credentials.dart';
import '../repositories/auth_repository.dart';

class GetSavedCredentialsUseCase {
  final AuthRepository repository;

  GetSavedCredentialsUseCase(this.repository);

  Future<Either<Failure, RouterCredentials?>> call() async {
    return await repository.getSavedCredentials();
  }
}
