import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupParams {
  final String name;
  final String? password;

  const RestoreBackupParams({
    required this.name,
    this.password,
  });
}

class RestoreBackupUseCase {
  final BackupRepository repository;

  RestoreBackupUseCase(this.repository);

  Future<Either<Failure, bool>> call(RestoreBackupParams params) async {
    return await repository.restoreBackup(
      name: params.name,
      password: params.password,
    );
  }
}