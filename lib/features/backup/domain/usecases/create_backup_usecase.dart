import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class CreateBackupParams {
  final String name;
  final String? password;
  final bool dontEncrypt;

  const CreateBackupParams({
    required this.name,
    this.password,
    this.dontEncrypt = true,
  });
}

class CreateBackupUseCase {
  final BackupRepository repository;

  CreateBackupUseCase(this.repository);

  Future<Either<Failure, bool>> call(CreateBackupParams params) async {
    return await repository.createBackup(
      name: params.name,
      password: params.password,
      dontEncrypt: params.dontEncrypt,
    );
  }
}