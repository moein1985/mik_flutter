import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/backup_file.dart';
import '../../domain/repositories/backup_repository.dart';

/// Fake implementation of BackupRepository for development without a real router
class FakeBackupRepositoryImpl implements BackupRepository {
  // In-memory backup store
  final List<BackupFile> _backups = [
    BackupFile(
      name: 'auto-backup-2024-12-10',
      size: '24.5 KB',
      created: DateTime.now().subtract(const Duration(days: 5)),
      type: 'backup',
    ),
    BackupFile(
      name: 'manual-backup-2024-12-08',
      size: '23.8 KB',
      created: DateTime.now().subtract(const Duration(days: 7)),
      type: 'backup',
    ),
    BackupFile(
      name: 'before-upgrade',
      size: '22.1 KB',
      created: DateTime.now().subtract(const Duration(days: 30)),
      type: 'backup',
    ),
  ];

  Future<void> _simulateDelay() => Future.delayed(AppConfig.fakeNetworkDelay);

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  @override
  Future<Either<Failure, List<BackupFile>>> getBackups() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load backups'));
    }
    return Right(List.from(_backups));
  }

  @override
  Future<Either<Failure, bool>> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  }) async {
    // Simulate longer delay for backup creation
    await Future.delayed(const Duration(seconds: 2));
    
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to create backup'));
    }

    // Check for duplicate name
    if (_backups.any((b) => b.name == name)) {
      return const Left(ServerFailure('Backup with this name already exists'));
    }

    final backup = BackupFile(
      name: name,
      size: '${(20 + (name.hashCode % 10))}.${(name.hashCode % 10)} KB',
      created: DateTime.now(),
      type: 'backup',
    );

    _backups.insert(0, backup); // Add to beginning (most recent first)
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> deleteBackup(String name) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to delete backup'));
    }

    final existed = _backups.any((b) => b.name == name);
    if (!existed) {
      return const Left(ServerFailure('Backup not found'));
    }

    _backups.removeWhere((b) => b.name == name);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> restoreBackup({
    required String name,
    String? password,
  }) async {
    // Simulate longer delay for restore operation
    await Future.delayed(const Duration(seconds: 3));
    
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to restore backup'));
    }

    // Check if backup exists
    if (!_backups.any((b) => b.name == name)) {
      return const Left(ServerFailure('Backup not found'));
    }

    // Simulate password validation
    if (password != null && password.isEmpty) {
      return const Left(ServerFailure('Invalid password'));
    }

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> exportConfig({
    required String fileName,
    bool compact = true,
    bool showSensitive = false,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to export configuration'));
    }

    if (fileName.isEmpty) {
      return const Left(ServerFailure('Invalid file name'));
    }

    // In a real implementation, this would generate and save a .rsc file
    return const Right(true);
  }
}
