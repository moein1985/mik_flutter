import 'routeros_base_client.dart';

/// Specialized client for RouterOS queue operations
class RouterOSQueuesClient extends RouterOSBaseClient {
  RouterOSQueuesClient({
    required super.host,
    required super.port,
    required super.useSsl,
  });

  /// Get all simple queues
  Future<List<Map<String, String>>> getSimpleQueues() async {
    return sendCommand(['/queue/simple/print']);
  }

  /// Add a simple queue
  Future<bool> addSimpleQueue({
    required String name,
    required String target,
    String? maxLimit,
    String? limitAt,
    int? priority,
    int? queue,
    String? comment,
    bool? disabled,
  }) async {
    final words = ['/queue/simple/add', '=name=$name', '=target=$target'];
    if (maxLimit != null) words.add('=max-limit=$maxLimit');
    if (limitAt != null) words.add('=limit-at=$limitAt');
    // Priority format: upload/download (same value for both)
    if (priority != null) words.add('=priority=$priority/$priority');
    if (queue != null) words.add('=queue=$queue');
    if (comment != null) words.add('=comment=$comment');
    if (disabled != null) words.add('=disabled=${disabled ? 'yes' : 'no'}');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Update a simple queue
  Future<bool> updateSimpleQueue({
    required String id,
    String? name,
    String? target,
    String? maxLimit,
    String? limitAt,
    int? priority,
    int? queue,
    String? comment,
    bool? disabled,
  }) async {
    final words = ['/queue/simple/set', '=.id=$id'];
    if (name != null) words.add('=name=$name');
    if (target != null) words.add('=target=$target');
    if (maxLimit != null) words.add('=max-limit=$maxLimit');
    if (limitAt != null) words.add('=limit-at=$limitAt');
    // Priority format: upload/download (same value for both)
    if (priority != null) words.add('=priority=$priority/$priority');
    if (queue != null) words.add('=queue=$queue');
    if (comment != null) words.add('=comment=$comment');
    if (disabled != null) words.add('=disabled=${disabled ? 'yes' : 'no'}');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Delete a simple queue
  Future<bool> deleteSimpleQueue(String id) async {
    final result = await sendCommand(['/queue/simple/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable a simple queue
  Future<bool> enableSimpleQueue(String id) async {
    final result = await sendCommand(['/queue/simple/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable a simple queue
  Future<bool> disableSimpleQueue(String id) async {
    final result = await sendCommand(['/queue/simple/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }
}