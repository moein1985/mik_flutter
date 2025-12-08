import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/backup_file.dart';
import '../repositories/backup_repository.dart';

class GetBackupsUseCase {
  final BackupRepository repository;

  GetBackupsUseCase(this.repository);

  Future<Either<Failure, List<BackupFile>>> call() async {
    return await repository.getBackups();
  }
}