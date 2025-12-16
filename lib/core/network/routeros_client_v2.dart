import 'dart:async';
import 'dart:io';
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
  
  // Store credentials for reconnection
  String? _username;
  String? _password;
  
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
      
      // Store credentials for reconnection
      _username = username;
      _password = password;
      
      // The package handles login internally
      // For SSL connections, we use onBadCertificate to accept self-signed certificates
      _client = ros.RouterOSClient(
        address: host,
        port: port,
        user: username,
        password: password,
        useSsl: useSsl,
        verbose: false,
        onBadCertificate: useSsl ? (certificate) {
          _log.w('Accepting self-signed certificate: ${certificate.subject}');
          return true; // Accept all certificates (for self-signed certs)
        } : null,
      );
      
      final success = await _client!.login();
      _isConnected = success;
      
      if (success) {
        _log.i('Login successful');
      } else {
        _log.w('Login failed - check username/password');
      }
      
      return success;
    } on ros.LoginError catch (e) {
      _log.e('Login error: ${e.message}');
      _isConnected = false;
      return false;
    } on HandshakeException catch (e) {
      _log.e('SSL Handshake failed - self-signed certificate? Error: $e');
      _isConnected = false;
      // Re-throw with more helpful message
      throw ConnectionException('SSL certificate verification failed. The router may be using a self-signed certificate.');
    } catch (e, stackTrace) {
      _log.e('Login failed with exception: $e');
      _log.d('Stack trace: $stackTrace');
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

  /// Reconnect to the router (useful after timeout)
  Future<void> reconnect() async {
    _log.i('Reconnecting...');
    disconnect();
    _wirelessType = null; // Reset wireless type detection
    _detectingWirelessType = null; // Reset detection completer
    await connect();
    
    // Re-login if we have stored credentials
    if (_username != null && _password != null) {
      _log.i('Re-authenticating after reconnect...');
      final success = await login(_username!, _password!);
      if (!success) {
        _log.e('Re-authentication failed after reconnect');
        throw ConnectionException('Failed to re-authenticate after reconnect');
      }
      _log.i('Re-authentication successful');
    }
  }

  /// Send a command and get response with timeout
  Future<List<Map<String, String>>> talk(
    dynamic command, [
    Map<String, String>? params,
    Duration timeout = const Duration(seconds: 15),
  ]) async {
    _ensureConnected();
    
    try {
      _log.d('Sending command: $command');
      final result = await _client!.talk(command, params).timeout(
        timeout,
        onTimeout: () {
          _log.e('Command timeout after ${timeout.inSeconds}s: $command');
          throw TimeoutException('Command timed out: $command', timeout);
        },
      );
      _log.d('Command response: ${result.length} items');
      return result;
    } on TimeoutException {
      // Try to reconnect after timeout
      _log.w('Attempting reconnect after timeout...');
      try {
        await reconnect();
      } catch (e) {
        _log.e('Reconnect failed', error: e);
      }
      rethrow;
    } on FormatException catch (e) {
      // UTF-8 decoding error - router sent invalid characters
      // This is a known issue with the router_os_client package
      _log.e('UTF-8 decoding error (invalid characters in response): $e');
      _log.w('Attempting reconnect after encoding error...');
      try {
        await reconnect();
      } catch (reconnectError) {
        _log.e('Reconnect failed', error: reconnectError);
      }
      // Rethrow as a more descriptive exception
      throw ServerException('Router sent invalid UTF-8 data. Please check interface names for special characters.');
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
    return response;
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
      await talk(['/interface/enable', '=.id=$id']);
      // RouterOS returns empty response on success, throwing on failure
      return true;
    } catch (e) {
      _log.e('Failed to enable interface $id: $e');
      return false;
    }
  }

  Future<bool> disableInterface(String id) async {
    try {
      await talk(['/interface/disable', '=.id=$id']);
      // RouterOS returns empty response on success, throwing on failure
      return true;
    } catch (e) {
      _log.e('Failed to disable interface $id: $e');
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
      await talk(cmd);
      return true;
    } catch (e) {
      _log.e('Failed to add IP address: $e');
      return false;
    }
  }

  Future<bool> removeIpAddress(String id) async {
    try {
      await talk(['/ip/address/remove', '=.id=$id']);
      return true;
    } catch (e) {
      _log.e('Failed to remove IP address $id: $e');
      return false;
    }
  }

  Future<bool> updateIpAddress({
    required String id,
    String? address,
    String? interfaceName,
    String? comment,
  }) async {
    try {
      final List<String> cmd = ['/ip/address/set', '=.id=$id'];
      if (address != null) {
        cmd.add('=address=$address');
      }
      if (interfaceName != null) {
        cmd.add('=interface=$interfaceName');
      }
      if (comment != null) {
        cmd.add('=comment=$comment');
      }
      await talk(cmd);
      return true;
    } catch (e) {
      _log.e('Failed to update IP address $id: $e');
      return false;
    }
  }

  Future<bool> toggleIpAddress(String id, bool enable) async {
    try {
      final command = enable ? '/ip/address/enable' : '/ip/address/disable';
      await talk([command, '=.id=$id']);
      return true;
    } catch (e) {
      _log.e('Failed to toggle IP address $id: $e');
      return false;
    }
  }

  // ==================== DHCP Methods ====================

  Future<List<Map<String, String>>> getDhcpServers() async {
    final response = await talk(['/ip/dhcp-server/print']);
    return response;
  }

  Future<bool> addDhcpServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    _log.d('Adding DHCP server: name=$name, interface=$interface, pool=$addressPool');
    final words = ['/ip/dhcp-server/add', '=name=$name', '=interface=$interface'];
    if (addressPool != null) words.add('=address-pool=$addressPool');
    if (leaseTime != null) words.add('=lease-time=$leaseTime');
    if (authoritative != null) words.add('=authoritative=${authoritative ? 'yes' : 'no'}');

    final response = await talk(words);
    _log.d('DHCP server add response: $response');
    final success = response.any((r) => r.containsKey('ret') || r['type'] == 'done');
    if (success) {
      _log.i('DHCP server added successfully');
    } else {
      _log.w('DHCP server add failed - unexpected response');
    }
    return success;
  }

  Future<bool> editDhcpServer({
    required String id,
    String? name,
    String? interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    final words = ['/ip/dhcp-server/set', '=.id=$id'];
    if (name != null) words.add('=name=$name');
    if (interface != null) words.add('=interface=$interface');
    if (addressPool != null) words.add('=address-pool=$addressPool');
    if (leaseTime != null) words.add('=lease-time=$leaseTime');
    if (authoritative != null) words.add('=authoritative=${authoritative ? 'yes' : 'no'}');

    await talk(words);
    return true;
  }

  Future<bool> removeDhcpServer(String id) async {
    // Remove command returns empty response on success (!done only)
    // If there's an error, talk() throws ServerException
    await talk(['/ip/dhcp-server/remove', '=.id=$id']);
    return true;
  }

  Future<bool> enableDhcpServer(String id) async {
    await talk(['/ip/dhcp-server/enable', '=.id=$id']);
    return true;
  }

  Future<bool> disableDhcpServer(String id) async {
    await talk(['/ip/dhcp-server/disable', '=.id=$id']);
    return true;
  }

  Future<List<Map<String, String>>> getDhcpNetworks() async {
    final response = await talk(['/ip/dhcp-server/network/print']);
    return response;
  }

  Future<bool> addDhcpNetwork({
    required String address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    try {
      final words = ['/ip/dhcp-server/network/add', '=address=$address'];
      if (gateway != null) words.add('=gateway=$gateway');
      if (netmask != null) words.add('=netmask=$netmask');
      if (dnsServer != null) words.add('=dns-server=$dnsServer');
      if (domain != null) words.add('=domain=$domain');
      if (comment != null) words.add('=comment=$comment');

      final response = await talk(words);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> editDhcpNetwork({
    required String id,
    String? address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    try {
      final words = ['/ip/dhcp-server/network/set', '=.id=$id'];
      if (address != null) words.add('=address=$address');
      if (gateway != null) words.add('=gateway=$gateway');
      if (netmask != null) words.add('=netmask=$netmask');
      if (dnsServer != null) words.add('=dns-server=$dnsServer');
      if (domain != null) words.add('=domain=$domain');
      if (comment != null) words.add('=comment=$comment');

      final response = await talk(words);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeDhcpNetwork(String id) async {
    try {
      final response = await talk(['/ip/dhcp-server/network/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getDhcpLeases() async {
    final response = await talk(['/ip/dhcp-server/lease/print']);
    return response;
  }

  Future<bool> addDhcpLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  }) async {
    try {
      final words = [
        '/ip/dhcp-server/lease/add',
        '=address=$address',
        '=mac-address=$macAddress',
      ];
      if (server != null) words.add('=server=$server');
      if (comment != null) words.add('=comment=$comment');

      final response = await talk(words);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeDhcpLease(String id) async {
    try {
      final response = await talk(['/ip/dhcp-server/lease/remove', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> makeDhcpLeaseStatic(String id) async {
    try {
      final response = await talk(['/ip/dhcp-server/lease/make-static', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> enableDhcpLease(String id) async {
    try {
      final response = await talk(['/ip/dhcp-server/lease/enable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  Future<bool> disableDhcpLease(String id) async {
    try {
      final response = await talk(['/ip/dhcp-server/lease/disable', '=.id=$id']);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== Pool Methods ====================

  Future<List<Map<String, String>>> getIpPools() async {
    final response = await talk(['/ip/pool/print']);
    return _filterProtocolMessages(response);
  }

  Future<bool> addIpPool({required String name, required String ranges}) async {
    try {
      _log.d('Adding IP pool: name=$name, ranges=$ranges');
      final response = await talk([
        '/ip/pool/add',
        '=name=$name',
        '=ranges=$ranges',
      ]);
      _log.d('Add IP pool response: $response');
      // Success if we get 'ret' (returned ID) or 'done' without error
      final success = response.any((r) => r.containsKey('ret') || r['type'] == 'done');
      if (success) {
        _log.i('IP pool added successfully');
      } else {
        _log.w('IP pool add failed - unexpected response');
      }
      return success;
    } catch (e) {
      _log.e('Failed to add IP pool: $e');
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
  /// 
  /// Note: Uses RouterOS :resolve command which only supports A and AAAA records
  /// 
  /// [name] - Domain name to lookup
  /// [recordType] - DNS record type (only A and AAAA are supported)
  /// [server] - DNS server to use (optional, uses router's default if not specified)
  Future<List<Map<String, String>>> dnsLookup({
    required String name,
    int timeout = 5000,
    String? recordType,
    String? server,
  }) async {
    try {
      _log.d('Starting DNS lookup for: $name (type: ${recordType ?? 'A'}, server: ${server ?? 'default'})');
      
      // Use :resolve command via script - works on all RouterOS versions
      // The /tool/dns-lookup command is not available via API
      return await _dnsLookupViaScript(name: name, server: server);
    } catch (e) {
      _log.e('DNS lookup failed for $name', error: e);
      rethrow;
    }
  }

  /// Fallback DNS lookup using RouterOS script command
  /// Works on all RouterOS versions that support scripting
  Future<List<Map<String, String>>> _dnsLookupViaScript({
    required String name,
    String? server,
  }) async {
    try {
      _log.d('Attempting DNS resolve via script for: $name');
      
      // Build the resolve script
      // :resolve is a global command that resolves DNS names
      String resolveScript;
      if (server != null && server.isNotEmpty) {
        resolveScript = ':put [:resolve "$name" server=$server]';
      } else {
        resolveScript = ':put [:resolve "$name"]';
      }
      
      List<Map<String, String>> filtered = [];
      final scriptName = '_dns_${DateTime.now().millisecondsSinceEpoch}';
      
      try {
        // Method: Create temp script, run it, parse output
        _log.d('Creating temp script: $scriptName');
        
        // Add temporary script
        final addResponse = await talk([
          '/system/script/add',
          '=name=$scriptName',
          '=source=$resolveScript',
          '=policy=read,write,test',
        ]);
        _log.d('Script add response: $addResponse');
        
        // Run the script and capture output
        _log.d('Running script...');
        final runResponse = await talk([
          '/system/script/run',
          '=.id=$scriptName',
        ]);
        _log.d('Script run response: $runResponse');
        filtered = _filterProtocolMessages(runResponse);
        
      } catch (scriptError) {
        _log.e('Script execution failed', error: scriptError);
        rethrow;
      } finally {
        // Always clean up - remove the temp script
        try {
          await talk(['/system/script/remove', '=.id=$scriptName']);
          _log.d('Temp script removed');
        } catch (_) {
          _log.w('Failed to remove temp script: $scriptName');
        }
      }
      
      // Parse the response
      final results = <Map<String, String>>[];
      _log.d('Parsing filtered response: $filtered');
      
      for (final item in filtered) {
        _log.d('Processing item: $item');
        // Check if there's a 'ret' key with the result (return value from :put)
        if (item.containsKey('ret')) {
          final ip = item['ret'] ?? '';
          _log.d('Found ret value: $ip');
          if (ip.isNotEmpty && _isValidIp(ip)) {
            results.add({
              'name': name,
              'address': ip,
              'type': ip.contains(':') ? 'AAAA' : 'A',
            });
          }
        }
        
        // Also check 'message' key (some versions return output in message)
        if (item.containsKey('message')) {
          final msg = item['message'] ?? '';
          _log.d('Found message value: $msg');
          if (_isValidIp(msg)) {
            results.add({
              'name': name,
              'address': msg,
              'type': msg.contains(':') ? 'AAAA' : 'A',
            });
          }
        }
      }
      
      // If no results from ret/message, try parsing all values
      if (results.isEmpty) {
        for (final item in filtered) {
          for (final entry in item.entries) {
            final value = entry.value;
            _log.d('Checking value: ${entry.key}=$value');
            if (_isValidIp(value)) {
              results.add({
                'name': name,
                'address': value,
                'type': value.contains(':') ? 'AAAA' : 'A',
              });
            }
          }
        }
      }
      
      if (results.isEmpty) {
        _log.w('DNS lookup returned no results for $name');
        // Return empty result instead of throwing
        results.add({
          'name': name,
          'address': '',
          'type': 'A',
          'error': 'No DNS result found',
        });
      } else {
        _log.i('DNS lookup successful: ${results.length} result(s) for $name');
      }
      
      return results;
    } catch (e) {
      _log.e('Script-based DNS lookup failed for $name', error: e);
      rethrow;
    }
  }

  /// Check if a string is a valid IP address (v4 or v6)
  bool _isValidIp(String value) {
    // Simple validation for IPv4
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    // Simple validation for IPv6
    final ipv6Regex = RegExp(r'^[0-9a-fA-F:]+$');
    
    return ipv4Regex.hasMatch(value) || 
           (value.contains(':') && ipv6Regex.hasMatch(value) && value.length > 4);
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
        .where((r) => r['list'] != null)
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

  // ==================== Wireless Methods ====================
  // Supports both new WiFi (/interface/wifi) and legacy Wireless (/interface/wireless)
  
  /// Detected wireless type: 'wifi' (new), 'wireless' (legacy), or null (not detected yet)
  String? _wirelessType;
  
  /// Cached wireless interfaces from detection (to avoid duplicate commands)
  List<Map<String, String>>? _cachedWirelessInterfaces;
  DateTime? _wirelessInterfacesCacheTime;
  static const Duration _wirelessCacheDuration = Duration(seconds: 5);
  
  /// Completer to prevent concurrent detectWirelessType calls
  Completer<String?>? _detectingWirelessType;
  
  /// Detect which wireless package is installed (wifi or wireless)
  Future<String?> detectWirelessType() async {
    // Return cached result
    if (_wirelessType != null) return _wirelessType;
    
    // If detection is already in progress, wait for it
    if (_detectingWirelessType != null && !_detectingWirelessType!.isCompleted) {
      _log.d('Wireless detection already in progress, waiting...');
      return await _detectingWirelessType!.future;
    }
    
    // Start new detection
    _detectingWirelessType = Completer<String?>();
    
    _log.d('Detecting wireless type...');
    
    try {
      // Try new WiFi first (RouterOS 7.13+)
      try {
        final wifiResult = await talk(['/interface/wifi/print']);
        final filtered = _filterProtocolMessages(wifiResult);
        _wirelessType = 'wifi';
        // Cache the result to avoid duplicate command in getWirelessInterfaces
        _cachedWirelessInterfaces = filtered;
        _wirelessInterfacesCacheTime = DateTime.now();
        _log.i('Detected WiFi package (new) with ${filtered.length} interfaces');
        _detectingWirelessType!.complete(_wirelessType);
        return _wirelessType;
      } on ServerException catch (e) {
        // This is expected - wifi package not available
        _log.d('WiFi package not available: $e');
      } on TimeoutException {
        // Timeout - don't set wirelessType to 'none', leave it null so it retries
        _log.w('WiFi detection timed out, will retry on next call');
        _detectingWirelessType!.complete(null);
        _detectingWirelessType = null; // Allow retry
        rethrow;
      } catch (e) {
        _log.d('WiFi package check error: $e');
      }
      
      // Try legacy Wireless
      try {
        final wirelessResult = await talk(['/interface/wireless/print']);
        final filtered = _filterProtocolMessages(wirelessResult);
        _wirelessType = 'wireless';
        // Cache the result to avoid duplicate command in getWirelessInterfaces
        _cachedWirelessInterfaces = filtered;
        _wirelessInterfacesCacheTime = DateTime.now();
        _log.i('Detected Wireless package (legacy) with ${filtered.length} interfaces');
        _detectingWirelessType!.complete(_wirelessType);
        return _wirelessType;
      } on ServerException catch (e) {
        // This is expected - wireless package not available
        _log.d('Wireless package not available: $e');
      } on TimeoutException {
        // Timeout - don't set wirelessType to 'none', leave it null so it retries
        _log.w('Wireless detection timed out, will retry on next call');
        _detectingWirelessType!.complete(null);
        _detectingWirelessType = null; // Allow retry
        rethrow;
      } catch (e) {
        _log.d('Wireless package check error: $e');
      }
      
      _log.w('No wireless package detected on this router');
      _wirelessType = 'none';
      _detectingWirelessType!.complete(null);
      return null;
    } catch (e) {
      // For any other error, reset detection state to allow retry
      if (_detectingWirelessType != null && !_detectingWirelessType!.isCompleted) {
        _detectingWirelessType!.completeError(e);
      }
      _detectingWirelessType = null;
      rethrow;
    }
  }
  
  /// Get the base path for wireless commands
  String _getWirelessBasePath() {
    if (_wirelessType == 'wifi') return '/interface/wifi';
    return '/interface/wireless';
  }

  /// Get wireless interfaces (supports both WiFi and Wireless)
  Future<List<Map<String, String>>> getWirelessInterfaces() async {
    try {
      await detectWirelessType();
    } on TimeoutException {
      // Detection timed out, return empty and let UI show retry option
      _log.w('Wireless detection timed out');
      return [];
    }
    
    if (_wirelessType == 'none' || _wirelessType == null) {
      _log.w('No wireless package available');
      return [];
    }
    
    // Use cached result if available and fresh (avoid duplicate command after detection)
    if (_cachedWirelessInterfaces != null && 
        _wirelessInterfacesCacheTime != null &&
        DateTime.now().difference(_wirelessInterfacesCacheTime!) < _wirelessCacheDuration) {
      _log.d('Using cached wireless interfaces (${_cachedWirelessInterfaces!.length} items)');
      final result = _cachedWirelessInterfaces!;
      // Clear cache after use to ensure fresh data on next explicit call
      _cachedWirelessInterfaces = null;
      _wirelessInterfacesCacheTime = null;
      return result;
    }
    
    _log.d('Getting wireless interfaces (type: $_wirelessType)');
    final basePath = _getWirelessBasePath();
    final response = await talk(['$basePath/print']);
    return _filterProtocolMessages(response);
  }

  /// Enable wireless interface
  Future<bool> enableWirelessInterface(String id) async {
    try {
      await detectWirelessType();
      if (_wirelessType == 'none' || _wirelessType == null) return false;
      
      _log.d('Enabling wireless interface: $id');
      final basePath = _getWirelessBasePath();
      await talk(['$basePath/enable', '=.id=$id']);
      return true;
    } catch (e) {
      _log.e('Failed to enable wireless interface', error: e);
      return false;
    }
  }

  /// Disable wireless interface
  Future<bool> disableWirelessInterface(String id) async {
    try {
      await detectWirelessType();
      if (_wirelessType == 'none' || _wirelessType == null) return false;
      
      _log.d('Disabling wireless interface: $id');
      final basePath = _getWirelessBasePath();
      await talk(['$basePath/disable', '=.id=$id']);
      return true;
    } catch (e) {
      _log.e('Failed to disable wireless interface', error: e);
      return false;
    }
  }

  /// Get wireless registrations (connected clients)
  Future<List<Map<String, String>>> getWirelessRegistrations({
    String? interface,
  }) async {
    await detectWirelessType();
    
    if (_wirelessType == 'none' || _wirelessType == null) {
      _log.w('No wireless package available');
      return [];
    }
    
    _log.d('Getting wireless registrations${interface != null ? " for $interface" : ""} (type: $_wirelessType)');
    final basePath = _getWirelessBasePath();
    final cmd = ['$basePath/registration-table/print'];
    if (interface != null) cmd.add('?interface=$interface');
    final response = await talk(cmd);
    return _filterProtocolMessages(response);
  }

  /// Scan for wireless networks
  /// Returns a list of found networks with their details
  Future<List<Map<String, String>>> scanWirelessNetworks({
    required String interfaceId,
    int? duration,
  }) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'none' || _wirelessType == null) {
        _log.w('No wireless package available for scanning');
        return [];
      }
      
      _log.d('Scanning wireless networks on interface: $interfaceId (duration: ${duration ?? 'default'})');
      final basePath = _getWirelessBasePath();
      
      // Build scan command
      final cmd = ['$basePath/scan', '=.id=$interfaceId'];
      if (duration != null) {
        cmd.add('=duration=$duration');
      }
      
      // Execute scan and wait for results
      final response = await talk(cmd);
      final results = _filterProtocolMessages(response);
      
      _log.i('Found ${results.length} wireless networks');
      return results;
    } catch (e) {
      _log.e('Failed to scan wireless networks', error: e);
      return [];
    }
  }

  /// Disconnect wireless client
  Future<bool> disconnectWirelessClient({
    required String interface,
    required String macAddress,
  }) async {
    try {
      await detectWirelessType();
      if (_wirelessType == 'none' || _wirelessType == null) return false;
      
      _log.d('Disconnecting wireless client: $macAddress from $interface');
      final basePath = _getWirelessBasePath();
      
      // Find the registration entry and remove it
      final regs = await talk([
        '$basePath/registration-table/print',
        '?interface=$interface',
        '?mac-address=$macAddress'
      ]);
      final filtered = _filterProtocolMessages(regs);
      for (final reg in filtered) {
        if (reg['.id'] != null) {
          await talk(['$basePath/registration-table/remove', '=.id=${reg['.id']}']);
        }
      }
      return true;
    } catch (e) {
      _log.e('Failed to disconnect wireless client', error: e);
      return false;
    }
  }

  /// Get wireless security profiles (legacy wireless only)
  /// For new WiFi, security is configured per-interface or in /interface/wifi/security
  Future<List<Map<String, String>>> getWirelessSecurityProfiles() async {
    await detectWirelessType();
    
    _log.d('Getting wireless security profiles');
    
    if (_wirelessType == 'wifi') {
      // New WiFi uses /interface/wifi/security
      try {
        final response = await talk(['/interface/wifi/security/print']);
        return _filterProtocolMessages(response);
      } catch (e) {
        _log.d('WiFi security profiles not available: $e');
        return [];
      }
    } else if (_wirelessType == 'wireless') {
      // Legacy wireless
      final response = await talk(['/interface/wireless/security-profiles/print']);
      return _filterProtocolMessages(response);
    }
    
    return [];
  }

  // ========== Wireless Access List ==========

  /// Get all wireless access list entries
  Future<List<Map<String, String>>> getWirelessAccessList() async {
    await detectWirelessType();
    if (_wirelessType == 'none' || _wirelessType == null) return [];
    
    _log.d('Getting wireless access list');
    final basePath = _getWirelessBasePath();
    
    try {
      final response = await talk(['$basePath/access-list/print']);
      return _filterProtocolMessages(response);
    } catch (e) {
      _log.e('Failed to get wireless access list', error: e);
      return [];
    }
  }

  /// Add wireless access list entry
  Future<bool> addWirelessAccessListEntry(Map<String, String> entry) async {
    await detectWirelessType();
    if (_wirelessType == 'none' || _wirelessType == null) return false;
    
    _log.d('Adding wireless access list entry: $entry');
    final basePath = _getWirelessBasePath();
    
    try {
      await talk(['$basePath/access-list/add', ...entry.entries.map((e) => '=${e.key}=${e.value}')]);
      return true;
    } catch (e) {
      _log.e('Failed to add wireless access list entry', error: e);
      return false;
    }
  }

  /// Remove wireless access list entry
  Future<bool> removeWirelessAccessListEntry(String id) async {
    await detectWirelessType();
    if (_wirelessType == 'none' || _wirelessType == null) return false;
    
    _log.d('Removing wireless access list entry: $id');
    final basePath = _getWirelessBasePath();
    
    try {
      await talk(['$basePath/access-list/remove', '=.id=$id']);
      return true;
    } catch (e) {
      _log.e('Failed to remove wireless access list entry', error: e);
      return false;
    }
  }

  /// Update wireless access list entry
  Future<bool> updateWirelessAccessListEntry(String id, Map<String, String> updates) async {
    await detectWirelessType();
    if (_wirelessType == 'none' || _wirelessType == null) return false;
    
    _log.d('Updating wireless access list entry $id: $updates');
    final basePath = _getWirelessBasePath();
    
    try {
      await talk([
        '$basePath/access-list/set',
        '=.id=$id',
        ...updates.entries.map((e) => '=${e.key}=${e.value}')
      ]);
      return true;
    } catch (e) {
      _log.e('Failed to update wireless access list entry', error: e);
      return false;
    }
  }

  /// Create wireless security profile
  Future<bool> createWirelessSecurityProfile({
    required String name,
    String? authenticationTypes,
    String? unicastCiphers,
    String? groupCiphers,
    String? wpaPreSharedKey,
    String? wpa2PreSharedKey,
    String? passphrase, // For new WiFi
    String? comment,
  }) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        // New WiFi security profile
        _log.d('Creating WiFi security profile: $name');
        final cmd = ['/interface/wifi/security/add', '=name=$name'];
        if (authenticationTypes != null) cmd.add('=authentication-types=$authenticationTypes');
        if (passphrase != null) cmd.add('=passphrase=$passphrase');
        if (comment != null) cmd.add('=comment=$comment');
        await talk(cmd);
        return true;
      } else if (_wirelessType == 'wireless') {
        // Legacy wireless
        _log.d('Creating wireless security profile: $name');
        final cmd = ['/interface/wireless/security-profiles/add', '=name=$name'];
        // Set mode=dynamic-keys when using WPA authentication
        // This is required for WinBox to properly display/edit the profile
        if (authenticationTypes != null && authenticationTypes.isNotEmpty) {
          cmd.add('=mode=dynamic-keys');
          cmd.add('=authentication-types=$authenticationTypes');
        }
        if (unicastCiphers != null) cmd.add('=unicast-ciphers=$unicastCiphers');
        if (groupCiphers != null) cmd.add('=group-ciphers=$groupCiphers');
        if (wpaPreSharedKey != null) cmd.add('=wpa-pre-shared-key=$wpaPreSharedKey');
        if (wpa2PreSharedKey != null) cmd.add('=wpa2-pre-shared-key=$wpa2PreSharedKey');
        if (comment != null) cmd.add('=comment=$comment');
        await talk(cmd);
        return true;
      }
      
      return false;
    } catch (e) {
      _log.e('Failed to create wireless security profile', error: e);
      return false;
    }
  }

  /// Update wireless security profile
  Future<bool> updateWirelessSecurityProfile({
    required String id,
    String? name,
    String? authenticationTypes,
    String? unicastCiphers,
    String? groupCiphers,
    String? wpaPreSharedKey,
    String? wpa2PreSharedKey,
    String? passphrase, // For new WiFi
    String? comment,
  }) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        _log.d('Updating WiFi security profile: $id');
        final cmd = ['/interface/wifi/security/set', '=.id=$id'];
        if (name != null) cmd.add('=name=$name');
        if (authenticationTypes != null) cmd.add('=authentication-types=$authenticationTypes');
        if (passphrase != null) cmd.add('=passphrase=$passphrase');
        if (comment != null) cmd.add('=comment=$comment');
        await talk(cmd);
        return true;
      } else if (_wirelessType == 'wireless') {
        _log.d('Updating wireless security profile: $id');
        final cmd = ['/interface/wireless/security-profiles/set', '=.id=$id'];
        if (name != null) cmd.add('=name=$name');
        // Set mode=dynamic-keys when using WPA authentication
        if (authenticationTypes != null && authenticationTypes.isNotEmpty) {
          cmd.add('=mode=dynamic-keys');
          cmd.add('=authentication-types=$authenticationTypes');
        }
        if (unicastCiphers != null) cmd.add('=unicast-ciphers=$unicastCiphers');
        if (groupCiphers != null) cmd.add('=group-ciphers=$groupCiphers');
        if (wpaPreSharedKey != null) cmd.add('=wpa-pre-shared-key=$wpaPreSharedKey');
        if (wpa2PreSharedKey != null) cmd.add('=wpa2-pre-shared-key=$wpa2PreSharedKey');
        if (comment != null) cmd.add('=comment=$comment');
        await talk(cmd);
        return true;
      }
      
      return false;
    } catch (e) {
      _log.e('Failed to update wireless security profile', error: e);
      return false;
    }
  }

  /// Delete wireless security profile
  Future<bool> deleteWirelessSecurityProfile(String id) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        _log.d('Deleting WiFi security profile: $id');
        await talk(['/interface/wifi/security/remove', '=.id=$id']);
        return true;
      } else if (_wirelessType == 'wireless') {
        _log.d('Deleting wireless security profile: $id');
        await talk(['/interface/wireless/security-profiles/remove', '=.id=$id']);
        return true;
      }
      
      return false;
    } catch (e) {
      _log.e('Failed to delete wireless security profile', error: e);
      return false;
    }
  }
  
  /// Get wireless type (wifi/wireless/none)
  String? get wirelessType => _wirelessType;
  
  /// Reset wireless type detection (useful after reconnect)
  void resetWirelessType() {
    _wirelessType = null;
  }

  /// Update wireless interface SSID
  Future<bool> updateWirelessInterfaceSsid(String interfaceId, String newSsid) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        _log.d('Updating WiFi interface SSID: $interfaceId -> $newSsid');
        await talk(['/interface/wifi/set', '=.id=$interfaceId', '=configuration.ssid=$newSsid']);
        return true;
      } else if (_wirelessType == 'wireless') {
        _log.d('Updating wireless interface SSID: $interfaceId -> $newSsid');
        await talk(['/interface/wireless/set', '=.id=$interfaceId', '=ssid=$newSsid']);
        return true;
      }
      
      return false;
    } catch (e) {
      _log.e('Failed to update wireless interface SSID', error: e);
      return false;
    }
  }

  /// Get security profile password for an interface
  Future<String?> getWirelessPassword(String securityProfileName) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        _log.d('Getting WiFi security passphrase for: $securityProfileName');
        final response = await talk([
          '/interface/wifi/security/print',
          '?name=$securityProfileName',
        ]);
        final filtered = _filterProtocolMessages(response);
        if (filtered.isNotEmpty) {
          return filtered.first['passphrase'] ?? '';
        }
      } else if (_wirelessType == 'wireless') {
        _log.d('Getting wireless security password for: $securityProfileName');
        final response = await talk([
          '/interface/wireless/security-profiles/print',
          '?name=$securityProfileName',
        ]);
        final filtered = _filterProtocolMessages(response);
        if (filtered.isNotEmpty) {
          // Return WPA2 key or WPA key
          return filtered.first['wpa2-pre-shared-key'] ?? 
                 filtered.first['wpa-pre-shared-key'] ?? '';
        }
      }
      
      return null;
    } catch (e) {
      _log.e('Failed to get wireless password', error: e);
      return null;
    }
  }

  /// Update wireless password (changes the security profile password)
  Future<bool> updateWirelessPassword(String securityProfileName, String newPassword) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        _log.d('Updating WiFi password for profile: $securityProfileName');
        await talk([
          '/interface/wifi/security/set',
          '=numbers=$securityProfileName',
          '=passphrase=$newPassword',
        ]);
        return true;
      } else if (_wirelessType == 'wireless') {
        _log.d('Updating wireless password for profile: $securityProfileName');
        await talk([
          '/interface/wireless/security-profiles/set',
          '=numbers=$securityProfileName',
          '=wpa-pre-shared-key=$newPassword',
          '=wpa2-pre-shared-key=$newPassword',
        ]);
        return true;
      }
      
      return false;
    } catch (e) {
      _log.e('Failed to update wireless password', error: e);
      return false;
    }
  }

  /// Add a virtual wireless interface
  /// [name] - interface name (e.g., wlan2)
  /// [ssid] - WiFi network name
  /// [masterInterface] - physical interface to bind to (e.g., wlan1)
  /// [securityProfile] - security profile name (optional, defaults to 'default')
  /// [disabled] - whether the interface should be disabled initially
  Future<bool> addVirtualWirelessInterface({
    String? name,
    required String ssid,
    required String masterInterface,
    String? securityProfile,
    bool disabled = false,
  }) async {
    try {
      await detectWirelessType();
      
      if (_wirelessType == 'wifi') {
        _log.d('Adding virtual WiFi interface: $ssid (master: $masterInterface)');
        final cmd = <String>[
          '/interface/wifi/add',
          '=master-interface=$masterInterface',
          '=configuration.ssid=$ssid',
        ];
        if (name != null && name.isNotEmpty) cmd.add('=name=$name');
        if (securityProfile != null && securityProfile.isNotEmpty) {
          cmd.add('=security=$securityProfile');
        }
        if (disabled) cmd.add('=disabled=yes');
        
        await talk(cmd);
        return true;
      } else if (_wirelessType == 'wireless') {
        _log.d('Adding virtual wireless interface: $ssid (master: $masterInterface)');
        final cmd = <String>[
          '/interface/wireless/add',
          '=master-interface=$masterInterface',
          '=ssid=$ssid',
          '=mode=ap-bridge',
        ];
        if (name != null && name.isNotEmpty) cmd.add('=name=$name');
        if (securityProfile != null && securityProfile.isNotEmpty) {
          cmd.add('=security-profile=$securityProfile');
        }
        if (disabled) cmd.add('=disabled=yes');
        
        await talk(cmd);
        return true;
      }
      
      return false;
    } catch (e) {
      _log.e('Failed to add virtual wireless interface', error: e);
      return false;
    }
  }

  /// Remove a wireless interface
  Future<bool> removeWirelessInterface(String id) async {
    try {
      await detectWirelessType();
      if (_wirelessType == 'none' || _wirelessType == null) return false;
      
      _log.d('Removing wireless interface: $id');
      final basePath = _getWirelessBasePath();
      await talk(['$basePath/remove', '=.id=$id']);
      return true;
    } catch (e) {
      _log.e('Failed to remove wireless interface', error: e);
      return false;
    }
  }

  // ==================== BACKUP & RESTORE METHODS ====================

  /// Get all backup files from router
  Future<List<Map<String, String>>> getBackupFiles() async {
    try {
      _log.d('Getting backup files');
      final result = await talk(['/file/print', '?type=backup']);
      _log.d('Found ${result.length} backup files');
      return result;
    } catch (e) {
      _log.e('Failed to get backup files', error: e);
      rethrow;
    }
  }

  /// Get all files from router (for viewing .rsc exports too)
  Future<List<Map<String, String>>> getAllFiles() async {
    try {
      _log.d('Getting all files');
      final result = await talk(['/file/print']);
      _log.d('Found ${result.length} files');
      return result;
    } catch (e) {
      _log.e('Failed to get files', error: e);
      rethrow;
    }
  }

  /// Create a backup file
  /// [name] - backup file name (without .backup extension)
  /// [password] - optional encryption password
  /// [dontEncrypt] - if true, backup won't be encrypted (faster)
  Future<bool> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  }) async {
    try {
      _log.d('Creating backup: $name (encrypted: ${!dontEncrypt})');
      final cmd = ['/system/backup/save', '=name=$name'];
      if (password != null && password.isNotEmpty && !dontEncrypt) {
        cmd.add('=password=$password');
      }
      if (dontEncrypt) {
        cmd.add('=dont-encrypt=yes');
      }
      await talk(cmd);
      _log.i('Backup created successfully: $name');
      return true;
    } catch (e) {
      _log.e('Failed to create backup', error: e);
      return false;
    }
  }

  /// Delete a file (backup or export)
  Future<bool> deleteFile(String fileName) async {
    try {
      _log.d('Deleting file: $fileName');
      // First find the file ID
      final files = await talk(['/file/print', '?name=$fileName']);
      if (files.isEmpty) {
        _log.w('File not found: $fileName');
        return false;
      }
      final fileId = files.first['.id'];
      if (fileId == null) {
        _log.w('File ID not found for: $fileName');
        return false;
      }
      await talk(['/file/remove', '=.id=$fileId']);
      _log.i('File deleted: $fileName');
      return true;
    } catch (e) {
      _log.e('Failed to delete file', error: e);
      return false;
    }
  }

  /// Restore from a backup file
  /// WARNING: This will reboot the router!
  Future<bool> restoreBackup({
    required String name,
    String? password,
  }) async {
    try {
      _log.d('Restoring backup: $name');
      final cmd = ['/system/backup/load', '=name=$name'];
      if (password != null && password.isNotEmpty) {
        cmd.add('=password=$password');
      }
      await talk(cmd);
      _log.i('Backup restore initiated: $name (router will reboot)');
      return true;
    } catch (e) {
      _log.e('Failed to restore backup', error: e);
      return false;
    }
  }

  /// Export configuration to .rsc file (text format)
  /// [fileName] - export file name (without .rsc extension)
  /// [compact] - if true, only export modified settings
  /// [showSensitive] - if true, include passwords in export
  Future<bool> exportConfig({
    required String fileName,
    bool compact = true,
    bool showSensitive = false,
  }) async {
    try {
      _log.d('Exporting config to: $fileName.rsc');
      final cmd = ['/export', '=file=$fileName'];
      if (compact) {
        cmd.add('=compact');
      }
      if (showSensitive) {
        cmd.add('=show-sensitive=yes');
      }
      await talk(cmd);
      _log.i('Config exported: $fileName.rsc');
      return true;
    } catch (e) {
      _log.e('Failed to export config', error: e);
      return false;
    }
  }

  /// Get file contents (for small files like .rsc exports)
  Future<String?> getFileContents(String fileName) async {
    try {
      _log.d('Getting file contents: $fileName');
      final result = await talk(['/file/print', '?name=$fileName', '=detail']);
      if (result.isNotEmpty && result.first.containsKey('contents')) {
        return result.first['contents'];
      }
      return null;
    } catch (e) {
      _log.e('Failed to get file contents', error: e);
      return null;
    }
  }
}
