import 'routeros_base_client.dart';

/// Specialized client for RouterOS backup operations
class RouterOSBackupClient extends RouterOSBaseClient {
  RouterOSBackupClient({
    required super.host,
    required super.port,
    required super.useSsl,
  });

  /// Get all available backups
  Future<List<Map<String, String>>> getBackups() async {
    return sendCommand(['/system/backup/print']);
  }

  /// Create a new backup
  Future<bool> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  }) async {
    final words = ['/system/backup/save', '=name=$name'];
    if (password != null && password.isNotEmpty) {
      words.add('=password=$password');
      words.add('=dont-encrypt=false');
    } else {
      words.add('=dont-encrypt=true');
    }

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Delete a backup
  Future<bool> deleteBackup(String name) async {
    final result = await sendCommand(['/system/backup/remove', '=name=$name']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Restore from backup
  Future<bool> restoreBackup(String name) async {
    final result = await sendCommand(['/system/backup/load', '=name=$name']);
    return result.isNotEmpty && result.first['ret'] == '';
  }
}