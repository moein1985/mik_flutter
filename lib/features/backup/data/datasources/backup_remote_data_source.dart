import '../../../../core/network/routeros_client.dart';
import '../models/backup_file_model.dart';

abstract class BackupRemoteDataSource {
  Future<List<BackupFileModel>> getBackups();
  Future<void> createBackup(String name);
  Future<void> deleteBackup(String name);
  Future<void> restoreBackup(String name);
  Future<void> downloadBackup(String name);
}

class BackupRemoteDataSourceImpl implements BackupRemoteDataSource {
  final RouterOSClient client;

  BackupRemoteDataSourceImpl(this.client);

  @override
  Future<List<BackupFileModel>> getBackups() async {
    final result = await client.getBackups();
    return result.map((map) => BackupFileModel.fromMap(map)).toList();
  }

  @override
  Future<void> createBackup(String name) async {
    await client.createBackup(name: name);
  }

  @override
  Future<void> deleteBackup(String name) async {
    await client.deleteBackup(name);
  }

  @override
  Future<void> restoreBackup(String name) async {
    await client.restoreBackup(name);
  }

  @override
  Future<void> downloadBackup(String name) async {
    // For now, just return - download functionality can be implemented later
    // This would typically involve file system operations
    throw UnimplementedError('Download backup not yet implemented');
  }
}