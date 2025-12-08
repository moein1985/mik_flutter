import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class DownloadBackupUseCase {
  final BackupRepository repository;

  DownloadBackupUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) async {
    return await repository.downloadBackup(name);
  }
}