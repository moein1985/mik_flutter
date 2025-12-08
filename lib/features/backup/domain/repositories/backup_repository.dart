import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/backup_file.dart';

abstract class BackupRepository {
  Future<Either<Failure, List<BackupFile>>> getBackups();
  Future<Either<Failure, void>> createBackup(String name);
  Future<Either<Failure, void>> deleteBackup(String name);
  Future<Either<Failure, void>> restoreBackup(String name);
  Future<Either<Failure, void>> downloadBackup(String name);
}