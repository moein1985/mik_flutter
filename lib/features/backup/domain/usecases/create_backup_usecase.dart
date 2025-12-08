import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUseCase {
  final BackupRepository repository;

  CreateBackupUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) async {
    return await repository.createBackup(name);
  }
}