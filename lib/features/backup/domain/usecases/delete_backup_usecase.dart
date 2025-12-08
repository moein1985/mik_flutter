import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class DeleteBackupUseCase {
  final BackupRepository repository;

  DeleteBackupUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) async {
    return await repository.deleteBackup(name);
  }
}