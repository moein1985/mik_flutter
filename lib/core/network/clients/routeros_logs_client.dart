import 'routeros_base_client.dart';

/// Specialized client for RouterOS logging operations
class RouterOSLogsClient extends RouterOSBaseClient {
  RouterOSLogsClient({
    required super.host,
    required super.port,
    required super.useSsl,
  });

  /// Get system logs
  Future<List<Map<String, String>>> getLogs({
    String? topics,
    String? time,
    int? count,
  }) async {
    final words = ['/log/print'];
    if (topics != null) words.add('=topics=$topics');
    if (time != null) words.add('=time=$time');
    if (count != null) words.add('=count=$count');

    return sendCommand(words);
  }

  /// Start following logs (streaming)
  Future<Stream<Map<String, String>>> followLogs({
    String? topics,
    bool follow = true,
  }) async {
    final words = ['/log/print'];
    if (topics != null) words.add('=topics=$topics');
    if (follow) words.add('=follow=yes');

    return startStream(words);
  }

  /// Clear logs
  Future<bool> clearLogs() async {
    final result = await sendCommand(['/log/clear']);
    return result.isNotEmpty && result.first['ret'] == '';
  }
}