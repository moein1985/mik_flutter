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
    } on ServerException {
      return Left(const ServerFailure('Failed to load backup files'));
    }
  }

  @override
  Future<Either<Failure, void>> createBackup(String name) async {
    try {
      await remoteDataSource.createBackup(name);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to create backup'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String name) async {
    try {
      await remoteDataSource.deleteBackup(name);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to delete backup'));
    }
  }

  @override
  Future<Either<Failure, void>> restoreBackup(String name) async {
    try {
      await remoteDataSource.restoreBackup(name);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to restore backup'));
    }
  }

  @override
  Future<Either<Failure, void>> downloadBackup(String name) async {
    try {
      await remoteDataSource.downloadBackup(name);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to download backup'));
    } catch (e) {
      return Left(const ServerFailure('Download backup not implemented'));
    }
  }
}