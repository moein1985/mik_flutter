import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/backup_file.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_remote_data_source.dart';

class BackupRepositoryImpl implements BackupRepository {
  final BackupRemoteDataSource remoteDataSource;

  BackupRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BackupFile>>> getBackups() async {
    try {
      final result = await remoteDataSource.getBackups();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load backup files: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  }) async {
    try {
      final result = await remoteDataSource.createBackup(
        name: name,
        password: password,
        dontEncrypt: dontEncrypt,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create backup: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBackup(String name) async {
    try {
      final result = await remoteDataSource.deleteBackup(name);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete backup: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restoreBackup({
    required String name,
    String? password,
  }) async {
    try {
      final result = await remoteDataSource.restoreBackup(
        name: name,
        password: password,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to restore backup: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> exportConfig({
    required String fileName,
    bool compact = true,
    bool showSensitive = false,
  }) async {
    try {
      final result = await remoteDataSource.exportConfig(
        fileName: fileName,
        compact: compact,
        showSensitive: showSensitive,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to export config: $e'));
    }
  }
}
