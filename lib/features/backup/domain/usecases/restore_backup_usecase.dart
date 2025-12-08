import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupUseCase {
  final BackupRepository repository;

  RestoreBackupUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) async {
    return await repository.restoreBackup(name);
  }
}