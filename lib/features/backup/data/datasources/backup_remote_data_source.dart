import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/routeros_client_v2.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/backup_file_model.dart';

abstract class BackupRemoteDataSource {
  Future<List<BackupFileModel>> getBackups();
  Future<bool> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  });
  Future<bool> deleteBackup(String name);
  Future<bool> restoreBackup({
    required String name,
    String? password,
  });
  Future<bool> exportConfig({
    required String fileName,
    bool compact = true,
    bool showSensitive = false,
  });
  Future<List<BackupFileModel>> getAllFiles();
}

class BackupRemoteDataSourceImpl implements BackupRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  BackupRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClientV2 get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<List<BackupFileModel>> getBackups() async {
    final result = await client.getBackupFiles();
    return result.map((map) => BackupFileModel.fromMap(map)).toList();
  }

  @override
  Future<List<BackupFileModel>> getAllFiles() async {
    final result = await client.getAllFiles();
    return result.map((map) => BackupFileModel.fromMap(map)).toList();
  }

  @override
  Future<bool> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  }) async {
    return await client.createBackup(
      name: name,
      password: password,
      dontEncrypt: dontEncrypt,
    );
  }

  @override
  Future<bool> deleteBackup(String name) async {
    return await client.deleteFile(name);
  }

  @override
  Future<bool> restoreBackup({
    required String name,
    String? password,
  }) async {
    return await client.restoreBackup(
      name: name,
      password: password,
    );
  }

  @override
  Future<bool> exportConfig({
    required String fileName,
    bool compact = true,
    bool showSensitive = false,
  }) async {
    return await client.exportConfig(
      fileName: fileName,
      compact: compact,
      showSensitive: showSensitive,
    );
  }
}
