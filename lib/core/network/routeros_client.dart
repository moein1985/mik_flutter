import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'routeros_protocol.dart';
import '../utils/logger.dart';

final _log = AppLogger.tag('RouterOSClient');

class RouterOSClient {
  final String host;
  final int port;
  Socket? _socket;
  final List<int> _buffer = [];
  bool _isConnected = false;

  final List<Map<String, String>> _responseData = [];
  Map<String, String> _currentReply = {};
  Completer<List<Map<String, String>>>? _activeCompleter;

  RouterOSClient({
    required this.host,
    required this.port,
  });

  bool get isConnected => _isConnected;

  /// Connect to RouterOS device
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 10));
      _isConnected = true;

      _socket!.listen(
        (data) {
          _buffer.addAll(data);
          _processBuffer();
        },
        onError: (error) {
          _isConnected = false;
          _activeCompleter?.completeError(error);
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  /// Disconnect from RouterOS device
  Future<void> disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Send a command to RouterOS
  Future<List<Map<String, String>>> sendCommand(List<String> words) async {
    if (!_isConnected || _socket == null) {
      _log.e('Not connected to RouterOS');
      throw Exception('Not connected to RouterOS');
    }

    _log.d('Sending command: ${words.first}');
    _responseData.clear();
    _currentReply = {};

    final encoded = RouterOSProtocol.encodeSentence(words);
    _socket!.add(encoded);

    final completer = Completer<List<Map<String, String>>>();
    _activeCompleter = completer;
    
    try {
      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _log.w('Command timeout: ${words.first}');
          throw TimeoutException('Response timeout');
        },
      );
      _log.d('Command response: ${result.length} items');
      return result;
    } catch (e) {
      _log.e('Command failed: ${words.first}', error: e);
      rethrow;
    }
  }

  /// Login to RouterOS
  Future<bool> login(String username, String password) async {
    try {
      final response = await sendCommand([
        '/login',
        '=name=$username',
        '=password=$password',
      ]);

      return response.isNotEmpty && 
             response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get system resources
  Future<List<Map<String, String>>> getSystemResources() async {
    return await sendCommand(['/system/resource/print']);
  }

  /// Get all interfaces
  Future<List<Map<String, String>>> getInterfaces() async {
    return await sendCommand(['/interface/print']);
  }

  /// Enable an interface
  Future<bool> enableInterface(String id) async {
    try {
      final response = await sendCommand([
        '/interface/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable an interface
  Future<bool> disableInterface(String id) async {
    try {
      final response = await sendCommand([
        '/interface/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get all IP addresses
  Future<List<Map<String, String>>> getIpAddresses() async {
    return await sendCommand(['/ip/address/print']);
  }

  /// Add IP address
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
      final response = await sendCommand(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove IP address
  Future<bool> removeIpAddress(String id) async {
    try {
      final response = await sendCommand([
        '/ip/address/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get firewall filter rules
  Future<List<Map<String, String>>> getFirewallRules() async {
    return await sendCommand(['/ip/firewall/filter/print', '=stats']);
  }

  /// Enable firewall rule
  Future<bool> enableFirewallRule(String id) async {
    try {
      final response = await sendCommand([
        '/ip/firewall/filter/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable firewall rule
  Future<bool> disableFirewallRule(String id) async {
    try {
      final response = await sendCommand([
        '/ip/firewall/filter/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get DHCP leases
  Future<List<Map<String, String>>> getDhcpLeases() async {
    return await sendCommand(['/ip/dhcp-server/lease/print']);
  }

  /// Get all IP pools
  Future<List<Map<String, String>>> getIpPools() async {
    return await sendCommand(['/ip/pool/print']);
  }

  /// Add an IP pool
  Future<bool> addIpPool({
    required String name,
    required String ranges,
  }) async {
    try {
      final response = await sendCommand([
        '/ip/pool/add',
        '=name=$name',
        '=ranges=$ranges',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Check if hotspot package is enabled
  Future<bool> isHotspotPackageEnabled() async {
    try {
      final response = await sendCommand(['/system/package/print']);
      final packages = response.where((r) => r['type'] != 'done').toList();
      
      // Look for hotspot package
      for (final pkg in packages) {
        if (pkg['name'] == 'hotspot') {
          // Check if disabled field is present and equals 'true'
          return pkg['disabled'] != 'true';
        }
      }
      
      // If hotspot package not found separately, check if it's part of routeros bundle
      // In newer RouterOS, hotspot is bundled with routeros package
      return true; // Assume enabled if not found as separate package
    } catch (e) {
      _log.e('Failed to check hotspot package', error: e);
      return false;
    }
  }

  void _processBuffer() {
    while (_buffer.isNotEmpty) {
      try {
        final (length, bytesRead) = RouterOSProtocol.decodeLength(_buffer);

        if (bytesRead + length > _buffer.length) {
          return;
        }

        if (length == 0) {
          _buffer.removeRange(0, bytesRead);
          
          if (_responseData.isNotEmpty && _activeCompleter != null) {
            final lastType = _responseData.last['type'];
            if (lastType == 'done' || lastType == 'trap') {
              if (!_activeCompleter!.isCompleted) {
                _activeCompleter!.complete(List.from(_responseData));
                _responseData.clear();
                _activeCompleter = null;
              }
            }
          }
          continue;
        }

        final wordBytes = _buffer.sublist(bytesRead, bytesRead + length);
        final word = utf8.decode(wordBytes);

        _buffer.removeRange(0, bytesRead + length);

        _handleWord(word);
      } catch (e) {
        return;
      }
    }
  }

  void _handleWord(String word) {
    if (word.startsWith('!')) {
      if (word == '!done') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
          _currentReply = {};
        }
        _responseData.add({'type': 'done'});
      } else if (word == '!trap') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
          _currentReply = {};
        }
        _responseData.add({'type': 'trap'});
      } else if (word == '!re') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
        }
        _currentReply = {'type': 're'};
      } else if (word == '!fatal') {
        _responseData.add({'type': 'fatal'});
      }
    } else if (word.startsWith('=')) {
      final parts = word.substring(1).split('=');
      if (parts.length >= 2) {
        final key = parts[0];
        final value = parts.sublist(1).join('=');
        _currentReply[key] = value;
      } else if (parts.length == 1) {
        _currentReply[parts[0]] = '';
      }
    }
  }

  // ==================== HotSpot Management ====================

  /// Get all hotspot servers
  Future<List<Map<String, String>>> getHotspotServers() async {
    return await sendCommand(['/ip/hotspot/print']);
  }

  /// Enable a hotspot server
  Future<bool> enableHotspotServer(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable a hotspot server
  Future<bool> disableHotspotServer(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get all hotspot users
  Future<List<Map<String, String>>> getHotspotUsers() async {
    return await sendCommand(['/ip/hotspot/user/print']);
  }

  /// Add a hotspot user
  Future<bool> addHotspotUser({
    required String name,
    required String password,
    String? profile,
    String? server,
    String? comment,
    // Limits
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/user/add',
        '=name=$name',
        '=password=$password',
      ];
      
      if (profile != null) {
        commands.add('=profile=$profile');
      }
      
      if (server != null) {
        commands.add('=server=$server');
      }
      
      if (comment != null) {
        commands.add('=comment=$comment');
      }
      
      // Limits
      if (limitUptime != null && limitUptime.isNotEmpty) {
        commands.add('=limit-uptime=$limitUptime');
      }
      
      if (limitBytesIn != null && limitBytesIn.isNotEmpty) {
        commands.add('=limit-bytes-in=$limitBytesIn');
      }
      
      if (limitBytesOut != null && limitBytesOut.isNotEmpty) {
        commands.add('=limit-bytes-out=$limitBytesOut');
      }
      
      if (limitBytesTotal != null && limitBytesTotal.isNotEmpty) {
        commands.add('=limit-bytes-total=$limitBytesTotal');
      }
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Edit a hotspot user
  Future<bool> editHotspotUser({
    required String id,
    String? name,
    String? password,
    String? profile,
    String? server,
    String? comment,
    // Limits
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/user/set',
        '=.id=$id',
      ];
      
      if (name != null) {
        commands.add('=name=$name');
      }
      
      if (password != null) {
        commands.add('=password=$password');
      }
      
      if (profile != null) {
        commands.add('=profile=$profile');
      }
      
      if (server != null) {
        commands.add('=server=$server');
      }
      
      if (comment != null) {
        commands.add('=comment=$comment');
      }
      
      // Limits - empty string means remove limit
      if (limitUptime != null) {
        commands.add('=limit-uptime=$limitUptime');
      }
      
      if (limitBytesIn != null) {
        commands.add('=limit-bytes-in=$limitBytesIn');
      }
      
      if (limitBytesOut != null) {
        commands.add('=limit-bytes-out=$limitBytesOut');
      }
      
      if (limitBytesTotal != null) {
        commands.add('=limit-bytes-total=$limitBytesTotal');
      }
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove a hotspot user
  Future<bool> removeHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Enable a hotspot user
  Future<bool> enableHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable a hotspot user
  Future<bool> disableHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Reset hotspot user counters (statistics)
  Future<bool> resetHotspotUserCounters(String id) async {
    try {
      _log.d('Resetting counters for user: $id');
      final response = await sendCommand([
        '/ip/hotspot/user/reset-counters',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to reset user counters', error: e);
      return false;
    }
  }

  /// Get all active hotspot users
  Future<List<Map<String, String>>> getHotspotActiveUsers() async {
    return await sendCommand(['/ip/hotspot/active/print']);
  }

  /// Disconnect a hotspot user
  Future<bool> disconnectHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/active/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get all hotspot profiles
  Future<List<Map<String, String>>> getHotspotProfiles() async {
    return await sendCommand(['/ip/hotspot/user/profile/print']);
  }

  /// Setup HotSpot on an interface
  /// This performs the basic hotspot setup similar to /ip hotspot setup command
  /// 
  /// [interface] - The interface name to setup hotspot on
  /// [addressPool] - Either an existing pool name OR a new range like "192.168.88.10-192.168.88.254"
  /// [dnsName] - Optional DNS name for the hotspot login page
  Future<bool> setupHotspot({
    required String interface,
    String? addressPool,
    String? dnsName,
  }) async {
    try {
      _log.i('Starting HotSpot setup on interface: $interface');
      
      // Determine if addressPool is an existing pool name or a range to create
      String? poolNameToUse;
      if (addressPool != null && addressPool.isNotEmpty) {
        // If it contains a dash and dots, it's likely a range
        if (addressPool.contains('-') && addressPool.contains('.')) {
          // It's a range, create a new pool
          poolNameToUse = 'hs-pool-1';
          _log.d('Creating new IP pool: $poolNameToUse with ranges: $addressPool');
          final poolResponse = await sendCommand([
            '/ip/pool/add',
            '=name=$poolNameToUse',
            '=ranges=$addressPool',
          ]);
          _log.d('Pool creation response: $poolResponse');
          // Check for trap (error)
          if (poolResponse.any((r) => r['type'] == 'trap')) {
            final errorMsg = poolResponse.firstWhere(
              (r) => r['type'] == 'trap',
              orElse: () => {},
            )['message'] ?? 'Unknown error';
            if (!errorMsg.contains('already')) {
              _log.w('Pool creation failed: $errorMsg');
            }
          }
        } else {
          // It's an existing pool name
          poolNameToUse = addressPool;
          _log.d('Using existing pool: $poolNameToUse');
        }
      }

      // Step 2: Create default hotspot user profile (ignore if exists)
      _log.d('Creating default hotspot user profile...');
      final userProfileResponse = await sendCommand([
        '/ip/hotspot/user/profile/add',
        '=name=default',
        '=shared-users=1',
      ]);
      _log.d('User profile response: $userProfileResponse');

      // Step 3: Create hotspot server profile
      final serverProfileName = 'hsprof1';
      _log.d('Creating hotspot server profile: $serverProfileName');
      final serverProfileCommands = [
        '/ip/hotspot/profile/add',
        '=name=$serverProfileName',
        '=hotspot-address=10.5.50.1',
        '=login-by=cookie,http-chap,http-pap',
      ];
      if (dnsName != null && dnsName.isNotEmpty) {
        serverProfileCommands.add('=dns-name=$dnsName');
      }
      final serverProfileResponse = await sendCommand(serverProfileCommands);
      _log.d('Server profile response: $serverProfileResponse');

      // Step 4: Add IP address to interface
      _log.d('Adding IP address to interface $interface...');
      final ipResponse = await sendCommand([
        '/ip/address/add',
        '=address=10.5.50.1/24',
        '=interface=$interface',
      ]);
      _log.d('IP address response: $ipResponse');

      // Step 5: Create the hotspot server
      _log.d('Creating hotspot server...');
      final hotspotCommands = [
        '/ip/hotspot/add',
        '=name=hotspot1',
        '=interface=$interface',
        '=profile=$serverProfileName',
        '=disabled=no',
      ];
      
      if (poolNameToUse != null) {
        hotspotCommands.add('=address-pool=$poolNameToUse');
      }
      
      final response = await sendCommand(hotspotCommands);
      _log.d('Hotspot add response: $response');
      
      // Check for success
      final hasDone = response.any((r) => r['type'] == 'done');
      final hasTrap = response.any((r) => r['type'] == 'trap');
      
      if (hasTrap) {
        final errorMsg = response.firstWhere(
          (r) => r['type'] == 'trap',
          orElse: () => {},
        )['message'] ?? 'Unknown error';
        _log.e('Hotspot creation failed: $errorMsg');
        // If it already exists, consider it success
        if (errorMsg.contains('already')) {
          _log.i('Hotspot already exists, considering as success');
          return true;
        }
        return false;
      }
      
      _log.i('Hotspot setup completed successfully');
      return hasDone;
    } catch (e, stackTrace) {
      _log.e('Hotspot setup failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
