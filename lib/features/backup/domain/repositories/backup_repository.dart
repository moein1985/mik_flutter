import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/backup_file.dart';

abstract class BackupRepository {
  Future<Either<Failure, List<BackupFile>>> getBackups();
  Future<Either<Failure, bool>> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  });
  Future<Either<Failure, bool>> deleteBackup(String name);
  Future<Either<Failure, bool>> restoreBackup({
    required String name,
    String? password,
  });
  Future<Either<Failure, bool>> exportConfig({
    required String fileName,
    bool compact = true,
    bool showSensitive = false,
  });
}