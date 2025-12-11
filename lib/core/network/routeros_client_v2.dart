import 'dart:async';
import 'package:router_os_client/router_os_client.dart' as ros;
import '../utils/logger.dart';
import '../errors/exceptions.dart';

final _log = AppLogger.tag('RouterOSClientV2');

/// Wrapper around router_os_client package with proper tag support
/// for concurrent streaming operations (logs, ping, traceroute)
class RouterOSClientV2 {
  final String host;
  final int port;
  final bool useSsl;
  
  ros.RouterOSClient? _client;
  bool _isConnected = false;
  
  // Track active streams by tag for proper cancellation
  final Map<String, StreamController<Map<String, String>>> _activeStreams = {};

  RouterOSClientV2({
    required this.host,
    required this.port,
    this.useSsl = false,
  });

  bool get isConnected => _isConnected;

  /// Connect to RouterOS device
  Future<void> connect() async {
    if (_isConnected && _client != null) return;

    try {
      _log.i('Connecting ${useSsl ? "with SSL" : "without SSL"} to $host:$port');
      
      _client = ros.RouterOSClient(
        address: host,
        port: port,
        useSsl: useSsl,
        verbose: false, // Set to true for debugging
      );
      
      _isConnected = true;
      _log.i('Connected successfully (SSL: $useSsl)');
    } catch (e) {
      _log.e('Connection failed (SSL: $useSsl)', error: e);
      _isConnected = false;
      
      if (e is ros.CreateSocketError) {
        throw ConnectionException('Failed to create socket: ${e.message}');
      }
      rethrow;
    }
  }

  /// Login to RouterOS
  Future<bool> login(String username, String password) async {
    if (_client == null) {
      throw ConnectionException('Not connected to RouterOS');
    }

    try {
      _log.d('Logging in as $username');
      
      // The package handles login internally
      _client = ros.RouterOSClient(
        address: host,
        port: port,
        user: username,
        password: password,
        useSsl: useSsl,
        verbose: false,
      );
      
      final success = await _client!.login();
      _isConnected = success;
      
      if (success) {
        _log.i('Login successful');
      } else {
        _log.w('Login failed');
      }
      
      return success;
    } on ros.LoginError catch (e) {
      _log.e('Login error: ${e.message}');
      _isConnected = false;
      return false;
    } catch (e) {
      _log.e('Login failed', error: e);
      _isConnected = false;
      return false;
    }
  }

  /// Disconnect from RouterOS device
  Future<void> disconnect() async {
    // Close all active streams
    for (final entry in _activeStreams.entries) {
      final tag = entry.key;
      final controller = entry.value;
      
      if (!controller.isClosed) {
        try {
          await _client?.cancelTagged(tag);
        } catch (e) {
          _log.w('Error cancelling stream $tag: $e');
        }
        controller.close();
      }
    }
    _activeStreams.clear();
    
    _client?.close();
    _client = null;
    _isConnected = false;
    _log.i('Disconnected');
  }

  /// Send a command and get response
  Future<List<Map<String, String>>> talk(
    dynamic command, [
    Map<String, String>? params,
  ]) async {
    _ensureConnected();
    
    try {
      _log.d('Sending command: $command');
      final result = await _client!.talk(command, params);
      _log.d('Command response: ${result.length} items');
      return result;
    } on ros.RouterOSTrapError catch (e) {
      _log.e('RouterOS trap error: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      _log.e('Command failed', error: e);
      rethrow;
    }
  }

  /// Send command (alias for talk, for backward compatibility)
  Future<List<Map<String, String>>> sendCommand(
    List<String> words, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return talk(words);
  }

  /// Stream data from a command with tag support
  /// Returns a tuple of (Stream, tag) so caller can cancel specific stream
  (Stream<Map<String, String>>, String) streamDataWithTag(
    String command, [
    Map<String, String>? params,
    String? customTag,
  ]) {
    _ensureConnected();
    
    final tag = customTag ?? _generateTag(command);
    final controller = StreamController<Map<String, String>>();
    _activeStreams[tag] = controller;
    
    _log.i('Starting stream: $command (tag: $tag)');
    
    // Start streaming in background
    _startStreaming(command, params, tag, controller);
    
    return (controller.stream, tag);
  }

  /// Start streaming and pipe to controller
  Future<void> _startStreaming(
    String command,
    Map<String, String>? params,
    String tag,
    StreamController<Map<String, String>> controller,
  ) async {
    _log.d('_startStreaming: Starting $command with params: $params, tag: $tag');
    try {
      _log.d('_startStreaming: Calling _client!.streamData...');
      int dataCount = 0;
      await for (final data in _client!.streamData(command, params, tag)) {
        dataCount++;
        _log.d('_startStreaming: Received data #$dataCount: $data');
        if (controller.isClosed) {
          _log.d('_startStreaming: Controller is closed, breaking loop');
          break;
        }
        controller.add(data);
        _log.d('_startStreaming: Data added to controller');
      }
      
      // Stream completed normally
      _log.d('_startStreaming: Stream loop finished, total data: $dataCount');
      if (!controller.isClosed) {
        controller.close();
      }
      _activeStreams.remove(tag);
      _log.d('Stream completed: $tag');
    } catch (e, stackTrace) {
      _log.e('Stream error ($tag): $e', error: e);
      _log.e('Stack trace: $stackTrace');
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
      _activeStreams.remove(tag);
    }
  }

  /// Stop a specific stream by tag
  Future<void> stopStream(String tag) async {
    if (!_activeStreams.containsKey(tag)) {
      _log.w('Stream not found: $tag');
      return;
    }
    
    _log.i('Stopping stream: $tag');
    
    try {
      await _client?.cancelTagged(tag);
    } catch (e) {
      _log.w('Error cancelling stream: $e');
    }
    
    final controller = _activeStreams[tag];
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
    _activeStreams.remove(tag);
  }

  /// Stop all active streams (legacy method for compatibility)
  void stopStreaming() {
    for (final tag in _activeStreams.keys.toList()) {
      stopStream(tag);
    }
  }

  /// Generate unique tag for a command
  String _generateTag(String command) {
    final prefix = command
        .replaceAll('/', '_')
        .replaceAll(' ', '_')
        .replaceAll('=', '')
        .substring(0, command.length.clamp(0, 20));
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _ensureConnected() {
    if (!_isConnected || _client == null) {
      throw ConnectionException('Not connected to RouterOS');
    }
  }

  // ==================== Helper Methods ====================

  /// Filter out protocol messages from response
  List<Map<String, String>> _filterProtocolMessages(List<Map<String, String>> response) {
    return response.where((item) {
      final type = item['type'];
      return type == null || type == 're' || (type != 'done' && type != 'trap' && type != 'fatal');
    }).toList();
  }

  // ==================== System Methods ====================

  Future<List<Map<String, String>>> getSystemResources() async {
    final response = await talk(['/system/resource/print']);
    return _filterProtocolMessages(response);
  }

  // ==================== Interface Methods ====================

  Future<List<Map<String, String>>> getInterfaces() async {
    final response = await talk(['/interface/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> enableInterface(String id) async {
    try {
      final response = await talk(['/interface/enable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> disableInterface(String id) async {
    try {
      final response = await talk(['/interface/disable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> monitorTraffic(String interfaceName) async {
    try {
      final response = await talk([
        '/interface/monitor-traffic',
        '=interface=$interfaceName',
        '=once=',
      ]);
      
      for (final item in response) {
        if (item['type'] != 'done' && item['type'] != 'trap') {
          return item;
        }
      }
      return {};
    } catch (e) {
      _log.e('Monitor traffic failed for $interfaceName', error: e);
      return {};
    }
  }

  // ==================== IP Methods ====================

  Future<List<Map<String, String>>> getIpAddresses() async {
    final response = await talk(['/ip/address/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    try {
      final List<String> cmd = [
        '/ip/address/add',
        '=address=$address',
        '=interface=$interfaceName',
      ];
      if (comment != null && comment.isNotEmpty) {
        cmd.add('=comment=$comment');
      }
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeIpAddress(String id) async {
    try {
      final response = await talk(['/ip/address/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== DHCP Methods ====================

  Future<List<Map<String, String>>> getDhcpLeases() async {
    final response = await talk(['/ip/dhcp-server/lease/print']);
    return _filterProtocolMessages(response);
  }

  // ==================== Pool Methods ====================

  Future<List<Map<String, String>>> getIpPools() async {
    final response = await talk(['/ip/pool/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addIpPool({required String name, required String ranges}) async {
    try {
      final response = await talk([
        '/ip/pool/add',
        '=name=$name',
        '=ranges=$ranges',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeIpPool(String id) async {
    try {
      final response = await talk(['/ip/pool/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== Network Tools ====================

  /// Ping with streaming support
  (Stream<Map<String, String>>, String) pingStream({
    required String address,
    int count = 100,
    int interval = 1,
  }) {
    _log.i('Starting streaming ping to: $address');
    
    final params = <String, String>{
      'address': address,
      'count': count.toString(),
      'interval': interval.toString(),
    };
    return streamDataWithTag('/tool/ping', params, 'ping_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Non-streaming ping
  Future<List<Map<String, String>>> ping({
    required String address,
    int count = 4,
    int? size,
    int? ttl,
  }) async {
    try {
      _log.d('Starting ping to: $address (count: $count)');
      final command = [
        '/tool/ping',
        '=address=$address',
        '=count=$count',
      ];
      if (size != null) command.add('=size=$size');
      if (ttl != null) command.add('=ttl=$ttl');
      
      final response = await talk(command);
      return _filterProtocolMessages(response);
    } catch (e) {
      _log.e('Ping failed for $address', error: e);
      rethrow;
    }
  }

  /// Traceroute with streaming support
  (Stream<Map<String, String>>, String) tracerouteStream({
    required String address,
    int maxHops = 30,
  }) {
    _log.i('Starting streaming traceroute to: $address');
    
    final params = <String, String>{
      'address': address,
      'count': '3',
    };
    return streamDataWithTag('/tool/traceroute', params, 'traceroute_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Non-streaming traceroute
  Future<List<Map<String, String>>> traceroute({
    required String address,
    int maxHops = 30,
    int timeout = 1000,
  }) async {
    try {
      _log.d('Starting traceroute to: $address (max-hops: $maxHops)');
      final response = await talk([
        '/tool/traceroute',
        '=address=$address',
        '=count=3',
      ]);
      return _filterProtocolMessages(response);
    } catch (e) {
      _log.e('Traceroute failed for $address', error: e);
      rethrow;
    }
  }

  /// DNS Lookup
  Future<List<Map<String, String>>> dnsLookup({
    required String name,
    int timeout = 5000,
  }) async {
    try {
      _log.d('Starting DNS lookup for: $name');
      final response = await talk(['/tool/dns-lookup', '=name=$name']);
      return _filterProtocolMessages(response);
    } catch (e) {
      _log.e('DNS lookup failed for $name', error: e);
      rethrow;
    }
  }

  // ==================== Logs Methods ====================

  /// Get logs (non-streaming)
  Future<List<Map<String, String>>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  }) async {
    try {
      final command = ['/log/print'];
      // No count limit - get all logs
      if (topics != null && topics.isNotEmpty) {
        command.add('?topics~$topics');
      }
      
      final response = await talk(command);
      final filtered = _filterProtocolMessages(response);
      _log.d('Retrieved ${filtered.length} log entries');
      return filtered;
    } catch (e) {
      _log.e('Failed to get logs', error: e);
      rethrow;
    }
  }

  /// Follow logs in real-time with streaming and tag support
  (Stream<Map<String, String>>, String) followLogs({String? topics}) {
    _log.i('Starting to follow logs${topics != null ? " (topics: $topics)" : ""}');
    
    final params = <String, String>{
      'follow-only': '',
    };
    if (topics != null && topics.isNotEmpty) {
      params['topics'] = topics;
    }
    
    return streamDataWithTag('/log/print', params, 'logs_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      await talk(['/log/warning/clear']);
      _log.d('Cleared all logs successfully');
    } catch (e) {
      _log.e('Failed to clear logs', error: e);
      rethrow;
    }
  }

  // ==================== Hotspot Methods ====================

  Future<List<Map<String, String>>> getHotspotServers() async {
    final response = await talk(['/ip/hotspot/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> enableHotspotServer(String id) async {
    try {
      final response = await talk(['/ip/hotspot/enable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> disableHotspotServer(String id) async {
    try {
      final response = await talk(['/ip/hotspot/disable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getHotspotUsers() async {
    final response = await talk(['/ip/hotspot/user/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addHotspotUser({
    required String name,
    String? password,
    String? profile,
    String? limitUptime,
    String? limitBytesTotal,
    String? macAddress,
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/user/add', '=name=$name'];
      if (password != null) cmd.add('=password=$password');
      if (profile != null) cmd.add('=profile=$profile');
      if (limitUptime != null) cmd.add('=limit-uptime=$limitUptime');
      if (limitBytesTotal != null) cmd.add('=limit-bytes-total=$limitBytesTotal');
      if (macAddress != null) cmd.add('=mac-address=$macAddress');
      if (comment != null) cmd.add('=comment=$comment');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeHotspotUser(String id) async {
    try {
      final response = await talk(['/ip/hotspot/user/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateHotspotUser({
    required String id,
    String? name,
    String? password,
    String? profile,
    String? limitUptime,
    String? limitBytesTotal,
    String? macAddress,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/ip/hotspot/user/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (password != null) cmd.add('=password=$password');
      if (profile != null) cmd.add('=profile=$profile');
      if (limitUptime != null) cmd.add('=limit-uptime=$limitUptime');
      if (limitBytesTotal != null) cmd.add('=limit-bytes-total=$limitBytesTotal');
      if (macAddress != null) cmd.add('=mac-address=$macAddress');
      if (comment != null) cmd.add('=comment=$comment');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getHotspotActiveUsers() async {
    final response = await talk(['/ip/hotspot/active/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> kickHotspotActiveUser(String id) async {
    try {
      final response = await talk(['/ip/hotspot/active/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getHotspotProfiles() async {
    final response = await talk(['/ip/hotspot/user/profile/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addHotspotProfile({
    required String name,
    String? sharedUsers,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    String? addressPool,
    bool? addMacCookie,
    String? macCookieTimeout,
  }) async {
    try {
      final cmd = ['/ip/hotspot/user/profile/add', '=name=$name'];
      if (sharedUsers != null) cmd.add('=shared-users=$sharedUsers');
      if (rateLimit != null) cmd.add('=rate-limit=$rateLimit');
      if (sessionTimeout != null) cmd.add('=session-timeout=$sessionTimeout');
      if (idleTimeout != null) cmd.add('=idle-timeout=$idleTimeout');
      if (keepaliveTimeout != null) cmd.add('=keepalive-timeout=$keepaliveTimeout');
      if (addressPool != null) cmd.add('=address-pool=$addressPool');
      if (addMacCookie != null) cmd.add('=add-mac-cookie=${addMacCookie ? 'yes' : 'no'}');
      if (macCookieTimeout != null) cmd.add('=mac-cookie-timeout=$macCookieTimeout');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeHotspotProfile(String id) async {
    try {
      final response = await talk(['/ip/hotspot/user/profile/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateHotspotProfile({
    required String id,
    String? name,
    String? sharedUsers,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    String? addressPool,
    bool? addMacCookie,
    String? macCookieTimeout,
  }) async {
    try {
      final cmd = ['/ip/hotspot/user/profile/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (sharedUsers != null) cmd.add('=shared-users=$sharedUsers');
      if (rateLimit != null) cmd.add('=rate-limit=$rateLimit');
      if (sessionTimeout != null) cmd.add('=session-timeout=$sessionTimeout');
      if (idleTimeout != null) cmd.add('=idle-timeout=$idleTimeout');
      if (keepaliveTimeout != null) cmd.add('=keepalive-timeout=$keepaliveTimeout');
      if (addressPool != null) cmd.add('=address-pool=$addressPool');
      if (addMacCookie != null) cmd.add('=add-mac-cookie=${addMacCookie ? 'yes' : 'no'}');
      if (macCookieTimeout != null) cmd.add('=mac-cookie-timeout=$macCookieTimeout');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getHotspotIpBindings() async {
    final response = await talk(['/ip/hotspot/ip-binding/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addHotspotIpBinding({
    required String address,
    String? macAddress,
    String? server,
    String? type,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/ip/hotspot/ip-binding/add', '=address=$address'];
      if (macAddress != null) cmd.add('=mac-address=$macAddress');
      if (server != null) cmd.add('=server=$server');
      if (type != null) cmd.add('=type=$type');
      if (comment != null) cmd.add('=comment=$comment');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeHotspotIpBinding(String id) async {
    try {
      final response = await talk(['/ip/hotspot/ip-binding/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getHotspotHosts() async {
    final response = await talk(['/ip/hotspot/host/print']);
    return _filterProtocolMessages(response);
  }

  Future<List<Map<String, String>>> getWalledGarden() async {
    final response = await talk(['/ip/hotspot/walled-garden/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addWalledGardenEntry({
    String? dstHost,
    String? dstPort,
    String? path,
    String? action,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/ip/hotspot/walled-garden/add'];
      if (dstHost != null) cmd.add('=dst-host=$dstHost');
      if (dstPort != null) cmd.add('=dst-port=$dstPort');
      if (path != null) cmd.add('=path=$path');
      if (action != null) cmd.add('=action=$action');
      if (comment != null) cmd.add('=comment=$comment');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeWalledGardenEntry(String id) async {
    try {
      final response = await talk(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getWalledGardenIp() async {
    final response = await talk(['/ip/hotspot/walled-garden/ip/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addWalledGardenIpEntry({
    String? dstAddress,
    String? srcAddress,
    String? action,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/ip/hotspot/walled-garden/ip/add'];
      if (dstAddress != null) cmd.add('=dst-address=$dstAddress');
      if (srcAddress != null) cmd.add('=src-address=$srcAddress');
      if (action != null) cmd.add('=action=$action');
      if (comment != null) cmd.add('=comment=$comment');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeWalledGardenIpEntry(String id) async {
    try {
      final response = await talk(['/ip/hotspot/walled-garden/ip/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== Firewall Methods ====================

  Future<List<Map<String, String>>> getFirewallRules(String path) async {
    final response = await talk(['$path/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addFirewallRule(String path, Map<String, String> params) async {
    try {
      final cmd = ['$path/add'];
      params.forEach((key, value) {
        cmd.add('=$key=$value');
      });
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFirewallRule(String path, String id) async {
    try {
      final response = await talk(['$path/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> enableFirewallRule(String path, String id) async {
    try {
      final response = await talk(['$path/enable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> disableFirewallRule(String path, String id) async {
    try {
      final response = await talk(['$path/disable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getAddressListByName(String listName) async {
    final response = await talk([
      '/ip/firewall/address-list/print',
      '?list=$listName',
    ]);
    return _filterProtocolMessages(response);
  }

  /// Get unique address list names (lightweight)
  Future<List<String>> getAddressListNames() async {
    _log.d('Getting address list names only');
    // Use proplist to get only the 'list' field - much faster for large lists
    final response = await talk([
      '/ip/firewall/address-list/print',
      '=.proplist=list',
    ]);
    
    // Extract unique list names
    final names = response
        .where((r) => r['type'] == 're' && r['list'] != null)
        .map((r) => r['list']!)
        .toSet()
        .toList();
    
    names.sort();
    _log.d('Found ${names.length} unique address list names');
    return names;
  }

  // ==================== Certificate Methods ====================

  Future<List<Map<String, String>>> getCertificates() async {
    final response = await talk(['/certificate/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int days = 365,
    String? country,
    String? state,
    String? locality,
    String? organization,
    String? unit,
    String? subjectAltName,
    String? keyUsage,
  }) async {
    try {
      final cmd = [
        '/certificate/add',
        '=name=$name',
        '=common-name=$commonName',
        '=key-size=$keySize',
        '=days-valid=$days',
      ];
      if (country != null) cmd.add('=country=$country');
      if (state != null) cmd.add('=state=$state');
      if (locality != null) cmd.add('=locality=$locality');
      if (organization != null) cmd.add('=organization=$organization');
      if (unit != null) cmd.add('=unit=$unit');
      if (subjectAltName != null) cmd.add('=subject-alt-name=$subjectAltName');
      if (keyUsage != null) cmd.add('=key-usage=$keyUsage');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> signCertificate({
    required String certId,
    String? ca,
    String? caKeyPassphrase,
  }) async {
    try {
      final cmd = ['/certificate/sign', '=.id=$certId'];
      if (ca != null) cmd.add('=ca=$ca');
      if (caKeyPassphrase != null) cmd.add('=ca-key-passphrase=$caKeyPassphrase');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeCertificate(String id) async {
    try {
      final response = await talk(['/certificate/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== Services Methods ====================

  Future<List<Map<String, String>>> getServices() async {
    final response = await talk(['/ip/service/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> updateService({
    required String name,
    String? port,
    String? address,
    String? certificate,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/ip/service/set', '=.id=$name'];
      if (port != null) cmd.add('=port=$port');
      if (address != null) cmd.add('=address=$address');
      if (certificate != null) cmd.add('=certificate=$certificate');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      
      final response = await talk(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== System Identity ====================

  Future<String?> getSystemIdentity() async {
    try {
      final response = await talk(['/system/identity/print']);
      final filtered = _filterProtocolMessages(response);
      if (filtered.isNotEmpty) {
        return filtered.first['name'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setSystemIdentity(String name) async {
    try {
      final response = await talk(['/system/identity/set', '=name=$name']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== Package Check ====================

  Future<bool> isHotspotPackageInstalled() async {
    try {
      final response = await talk(['/system/package/print', '?name=hotspot']);
      final filtered = _filterProtocolMessages(response);
      if (filtered.isEmpty) return true;
      return filtered.any((p) => p['disabled'] != 'true');
    } catch (e) {
      return false;
    }
  }
}
