import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/router_credentials.dart';
import '../repositories/auth_repository.dart';

class SaveCredentialsUseCase {
  final AuthRepository repository;

  SaveCredentialsUseCase(this.repository);

  Future<Either<Failure, void>> call(RouterCredentials credentials) async {
    return await repository.saveCredentials(credentials);
  }
}
