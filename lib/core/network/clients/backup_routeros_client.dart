import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import 'base_routeros_client.dart';

class BackupRouterOSClient extends BaseRouterOSClient {
  BackupRouterOSClient(super.client);

  /// Get list of backup files
  Future<Either<Failure, List<Map<String, String>>>> getBackupFiles() async {
    return executeCommand(['/system/backup/print']);
  }

  /// Create a new backup
  Future<Either<Failure, void>> createBackup(String name) async {
    return executeVoidCommand([
      '/system/backup/save',
      '=name=$name',
    ]);
  }

  /// Restore from backup
  Future<Either<Failure, void>> restoreBackup(String name) async {
    return executeVoidCommand([
      '/system/backup/load',
      '=name=$name',
    ]);
  }

  /// Delete backup file
  Future<Either<Failure, void>> deleteBackup(String name) async {
    return executeVoidCommand([
      '/system/backup/remove',
      '=numbers=$name',
    ]);
  }

  /// Get backup file info
  Future<Either<Failure, Map<String, String>>> getBackupInfo(String name) async {
    final result = await executeCommand([
      '/system/backup/print',
      '?name=$name',
    ]);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data.isEmpty) {
          return Left(ServerFailure('Backup file not found'));
        }
        return Right(data.first);
      },
    );
  }
}