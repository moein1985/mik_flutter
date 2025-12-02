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
      
      // Limits - sanitize values (remove spaces)
      if (limitUptime != null && limitUptime.isNotEmpty) {
        final sanitized = _sanitizeTimeValue(limitUptime);
        if (sanitized.isNotEmpty) {
          commands.add('=limit-uptime=$sanitized');
        }
      }
      
      if (limitBytesIn != null && limitBytesIn.isNotEmpty) {
        final sanitized = _sanitizeBytesValue(limitBytesIn);
        if (sanitized.isNotEmpty) {
          commands.add('=limit-bytes-in=$sanitized');
        }
      }
      
      if (limitBytesOut != null && limitBytesOut.isNotEmpty) {
        final sanitized = _sanitizeBytesValue(limitBytesOut);
        if (sanitized.isNotEmpty) {
          commands.add('=limit-bytes-out=$sanitized');
        }
      }
      
      if (limitBytesTotal != null && limitBytesTotal.isNotEmpty) {
        final sanitized = _sanitizeBytesValue(limitBytesTotal);
        if (sanitized.isNotEmpty) {
          commands.add('=limit-bytes-total=$sanitized');
        }
      }
      
      _log.d('Adding user with commands: $commands');
      
      final response = await sendCommand(commands);
      _log.d('Add user response: $response');
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to add user: $errorMessage');
        throw Exception(errorMessage);
      }
      
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to add user', error: e);
      rethrow;
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
      
      // Limits - empty string means remove limit, otherwise sanitize
      if (limitUptime != null) {
        final sanitized = limitUptime.isEmpty ? '' : _sanitizeTimeValue(limitUptime);
        commands.add('=limit-uptime=$sanitized');
      }
      
      if (limitBytesIn != null) {
        final sanitized = limitBytesIn.isEmpty ? '' : _sanitizeBytesValue(limitBytesIn);
        commands.add('=limit-bytes-in=$sanitized');
      }
      
      if (limitBytesOut != null) {
        final sanitized = limitBytesOut.isEmpty ? '' : _sanitizeBytesValue(limitBytesOut);
        commands.add('=limit-bytes-out=$sanitized');
      }
      
      if (limitBytesTotal != null) {
        final sanitized = limitBytesTotal.isEmpty ? '' : _sanitizeBytesValue(limitBytesTotal);
        commands.add('=limit-bytes-total=$sanitized');
      }
      
      _log.d('Editing user with commands: $commands');
      
      final response = await sendCommand(commands);
      _log.d('Edit user response: $response');
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to edit user: $errorMessage');
        throw Exception(errorMessage);
      }
      
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to edit user', error: e);
      rethrow;
    }
  }

  /// Remove a hotspot user
  Future<bool> removeHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/remove',
        '=.id=$id',
      ]);
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to remove user: $errorMessage');
        throw Exception(errorMessage);
      }
      
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to remove user', error: e);
      rethrow;
    }
  }

  /// Enable a hotspot user
  Future<bool> enableHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/enable',
        '=.id=$id',
      ]);
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to enable user: $errorMessage');
        throw Exception(errorMessage);
      }
      
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to enable user', error: e);
      rethrow;
    }
  }

  /// Disable a hotspot user
  Future<bool> disableHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/disable',
        '=.id=$id',
      ]);
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to disable user: $errorMessage');
        throw Exception(errorMessage);
      }
      
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to disable user', error: e);
      rethrow;
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
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to reset counters: $errorMessage');
        throw Exception(errorMessage);
      }
      
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to reset user counters', error: e);
      rethrow;
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

  // ==================== HotSpot IP Bindings ====================

  /// Get all hotspot IP bindings
  Future<List<Map<String, String>>> getHotspotIpBindings() async {
    return await sendCommand(['/ip/hotspot/ip-binding/print']);
  }

  /// Add a hotspot IP binding
  Future<bool> addHotspotIpBinding({
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String type = 'regular',
    String? comment,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/ip-binding/add',
        '=type=$type',
      ];
      
      if (mac != null && mac.isNotEmpty) {
        commands.add('=mac-address=$mac');
      }
      if (address != null && address.isNotEmpty) {
        commands.add('=address=$address');
      }
      if (toAddress != null && toAddress.isNotEmpty) {
        commands.add('=to-address=$toAddress');
      }
      if (server != null && server.isNotEmpty) {
        commands.add('=server=$server');
      }
      if (comment != null && comment.isNotEmpty) {
        commands.add('=comment=$comment');
      }
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Edit a hotspot IP binding
  Future<bool> editHotspotIpBinding({
    required String id,
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String? type,
    String? comment,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/ip-binding/set',
        '=.id=$id',
      ];
      
      if (mac != null) commands.add('=mac-address=$mac');
      if (address != null) commands.add('=address=$address');
      if (toAddress != null) commands.add('=to-address=$toAddress');
      if (server != null) commands.add('=server=$server');
      if (type != null) commands.add('=type=$type');
      if (comment != null) commands.add('=comment=$comment');
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove a hotspot IP binding
  Future<bool> removeHotspotIpBinding(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/ip-binding/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Enable a hotspot IP binding
  Future<bool> enableHotspotIpBinding(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/ip-binding/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable a hotspot IP binding
  Future<bool> disableHotspotIpBinding(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/ip-binding/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== HotSpot Hosts ====================

  /// Get all hotspot hosts
  Future<List<Map<String, String>>> getHotspotHosts() async {
    return await sendCommand(['/ip/hotspot/host/print']);
  }

  /// Remove a hotspot host (kick from hotspot)
  Future<bool> removeHotspotHost(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/host/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Make a host binding from a host (bypass or block)
  Future<bool> makeHotspotHostBinding({
    required String id,
    required String type, // 'bypassed' or 'blocked'
  }) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/host/make-binding',
        '=.id=$id',
        '=type=$type',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== Walled Garden ====================

  /// Get all walled garden entries
  Future<List<Map<String, String>>> getWalledGarden() async {
    return await sendCommand(['/ip/hotspot/walled-garden/print']);
  }

  /// Add a walled garden entry
  Future<bool> addWalledGarden({
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String action = 'allow',
    String? method,
    String? comment,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/walled-garden/add',
        '=action=$action',
      ];
      
      if (server != null && server.isNotEmpty) {
        commands.add('=server=$server');
      }
      if (srcAddress != null && srcAddress.isNotEmpty) {
        commands.add('=src-address=$srcAddress');
      }
      if (dstAddress != null && dstAddress.isNotEmpty) {
        commands.add('=dst-address=$dstAddress');
      }
      if (dstHost != null && dstHost.isNotEmpty) {
        commands.add('=dst-host=$dstHost');
      }
      if (dstPort != null && dstPort.isNotEmpty) {
        commands.add('=dst-port=$dstPort');
      }
      if (path != null && path.isNotEmpty) {
        commands.add('=path=$path');
      }
      if (method != null && method.isNotEmpty) {
        commands.add('=method=$method');
      }
      if (comment != null && comment.isNotEmpty) {
        commands.add('=comment=$comment');
      }
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Edit a walled garden entry
  Future<bool> editWalledGarden({
    required String id,
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String? action,
    String? method,
    String? comment,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/walled-garden/set',
        '=.id=$id',
      ];
      
      if (server != null) commands.add('=server=$server');
      if (srcAddress != null) commands.add('=src-address=$srcAddress');
      if (dstAddress != null) commands.add('=dst-address=$dstAddress');
      if (dstHost != null) commands.add('=dst-host=$dstHost');
      if (dstPort != null) commands.add('=dst-port=$dstPort');
      if (path != null) commands.add('=path=$path');
      if (action != null) commands.add('=action=$action');
      if (method != null) commands.add('=method=$method');
      if (comment != null) commands.add('=comment=$comment');
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove a walled garden entry
  Future<bool> removeWalledGarden(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/walled-garden/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Enable a walled garden entry
  Future<bool> enableWalledGarden(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/walled-garden/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable a walled garden entry
  Future<bool> disableWalledGarden(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/walled-garden/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get walled garden IP entries (IP-level rules)
  Future<List<Map<String, String>>> getWalledGardenIp() async {
    return await sendCommand(['/ip/hotspot/walled-garden/ip/print']);
  }

  /// Add a walled garden IP entry
  Future<bool> addWalledGardenIp({
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstPort,
    String? protocol,
    String action = 'accept',
    String? comment,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/walled-garden/ip/add',
        '=action=$action',
      ];
      
      if (server != null && server.isNotEmpty) {
        commands.add('=server=$server');
      }
      if (srcAddress != null && srcAddress.isNotEmpty) {
        commands.add('=src-address=$srcAddress');
      }
      if (dstAddress != null && dstAddress.isNotEmpty) {
        commands.add('=dst-address=$dstAddress');
      }
      if (dstPort != null && dstPort.isNotEmpty) {
        commands.add('=dst-port=$dstPort');
      }
      if (protocol != null && protocol.isNotEmpty) {
        commands.add('=protocol=$protocol');
      }
      if (comment != null && comment.isNotEmpty) {
        commands.add('=comment=$comment');
      }
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== HotSpot User Profiles ====================

  /// Add a hotspot user profile
  Future<bool> addHotspotProfile({
    required String name,
    String? sessionTimeout,
    String? idleTimeout,
    String? sharedUsers,
    String? rateLimit,
    String? keepaliveTimeout,
    String? statusAutorefresh,
    String? onLogin,
    String? onLogout,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/user/profile/add',
        '=name=$name',
      ];
      
      if (sessionTimeout != null && sessionTimeout.isNotEmpty) {
        commands.add('=session-timeout=$sessionTimeout');
      }
      if (idleTimeout != null && idleTimeout.isNotEmpty) {
        commands.add('=idle-timeout=$idleTimeout');
      }
      if (sharedUsers != null && sharedUsers.isNotEmpty) {
        commands.add('=shared-users=$sharedUsers');
      }
      if (rateLimit != null && rateLimit.isNotEmpty) {
        commands.add('=rate-limit=$rateLimit');
      }
      if (keepaliveTimeout != null && keepaliveTimeout.isNotEmpty) {
        commands.add('=keepalive-timeout=$keepaliveTimeout');
      }
      if (statusAutorefresh != null && statusAutorefresh.isNotEmpty) {
        commands.add('=status-autorefresh=$statusAutorefresh');
      }
      if (onLogin != null && onLogin.isNotEmpty) {
        commands.add('=on-login=$onLogin');
      }
      if (onLogout != null && onLogout.isNotEmpty) {
        commands.add('=on-logout=$onLogout');
      }
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Edit a hotspot user profile
  Future<bool> editHotspotProfile({
    required String id,
    String? name,
    String? sessionTimeout,
    String? idleTimeout,
    String? sharedUsers,
    String? rateLimit,
    String? keepaliveTimeout,
    String? statusAutorefresh,
    String? onLogin,
    String? onLogout,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/user/profile/set',
        '=.id=$id',
      ];
      
      if (name != null) commands.add('=name=$name');
      if (sessionTimeout != null) commands.add('=session-timeout=$sessionTimeout');
      if (idleTimeout != null) commands.add('=idle-timeout=$idleTimeout');
      if (sharedUsers != null) commands.add('=shared-users=$sharedUsers');
      if (rateLimit != null) commands.add('=rate-limit=$rateLimit');
      if (keepaliveTimeout != null) commands.add('=keepalive-timeout=$keepaliveTimeout');
      if (statusAutorefresh != null) commands.add('=status-autorefresh=$statusAutorefresh');
      if (onLogin != null) commands.add('=on-login=$onLogin');
      if (onLogout != null) commands.add('=on-logout=$onLogout');
      
      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove a hotspot user profile
  Future<bool> removeHotspotProfile(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/profile/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  // ==================== HotSpot Reset ====================

  /// Reset HotSpot - Remove all HotSpot configuration
  /// This removes users, profiles, servers, IP bindings, walled garden entries, etc.
  Future<bool> resetHotspot({
    bool deleteUsers = true,
    bool deleteProfiles = true,
    bool deleteIpBindings = true,
    bool deleteWalledGarden = true,
    bool deleteServers = true,
    bool deleteServerProfiles = true,
    bool deleteIpPools = false,
  }) async {
    try {
      _log.i('Starting HotSpot reset...');
      
      // Order matters! Delete in the correct order to avoid dependency errors
      
      // 1. Remove all hotspot users first
      if (deleteUsers) {
        _log.d('Removing hotspot users...');
        final users = await getHotspotUsers();
        final userIds = users.where((r) => r['type'] != 'done').map((u) => u['.id']).whereType<String>().toList();
        for (final id in userIds) {
          await sendCommand(['/ip/hotspot/user/remove', '=.id=$id']);
        }
        _log.i('Removed ${userIds.length} hotspot users');
      }
      
      // 2. Remove all user profiles (except 'default' which is system profile)
      if (deleteProfiles) {
        _log.d('Removing hotspot user profiles...');
        final profiles = await getHotspotProfiles();
        final profileIds = profiles
            .where((r) => r['type'] != 'done' && r['name'] != 'default')
            .map((p) => p['.id'])
            .whereType<String>()
            .toList();
        for (final id in profileIds) {
          await sendCommand(['/ip/hotspot/user/profile/remove', '=.id=$id']);
        }
        _log.i('Removed ${profileIds.length} hotspot profiles');
      }
      
      // 3. Remove all IP bindings
      if (deleteIpBindings) {
        _log.d('Removing IP bindings...');
        final bindings = await getHotspotIpBindings();
        final bindingIds = bindings.where((r) => r['type'] != 'done').map((b) => b['.id']).whereType<String>().toList();
        for (final id in bindingIds) {
          await sendCommand(['/ip/hotspot/ip-binding/remove', '=.id=$id']);
        }
        _log.i('Removed ${bindingIds.length} IP bindings');
      }
      
      // 4. Remove all walled garden entries
      if (deleteWalledGarden) {
        _log.d('Removing walled garden entries...');
        final garden = await getWalledGarden();
        final gardenIds = garden.where((r) => r['type'] != 'done').map((g) => g['.id']).whereType<String>().toList();
        for (final id in gardenIds) {
          await sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
        }
        _log.i('Removed ${gardenIds.length} walled garden entries');
        
        // Also remove walled garden IP entries
        final gardenIp = await getWalledGardenIp();
        final gardenIpIds = gardenIp.where((r) => r['type'] != 'done').map((g) => g['.id']).whereType<String>().toList();
        for (final id in gardenIpIds) {
          await sendCommand(['/ip/hotspot/walled-garden/ip/remove', '=.id=$id']);
        }
        _log.i('Removed ${gardenIpIds.length} walled garden IP entries');
      }
      
      // 5. Remove all hotspot servers
      if (deleteServers) {
        _log.d('Removing hotspot servers...');
        final servers = await getHotspotServers();
        final serverIds = servers.where((r) => r['type'] != 'done').map((s) => s['.id']).whereType<String>().toList();
        for (final id in serverIds) {
          await sendCommand(['/ip/hotspot/remove', '=.id=$id']);
        }
        _log.i('Removed ${serverIds.length} hotspot servers');
      }
      
      // 6. Remove all hotspot server profiles
      if (deleteServerProfiles) {
        _log.d('Removing hotspot server profiles...');
        final serverProfiles = await sendCommand(['/ip/hotspot/profile/print']);
        final serverProfileIds = serverProfiles
            .where((r) => r['type'] != 'done')
            .map((p) => p['.id'])
            .whereType<String>()
            .toList();
        for (final id in serverProfileIds) {
          await sendCommand(['/ip/hotspot/profile/remove', '=.id=$id']);
        }
        _log.i('Removed ${serverProfileIds.length} hotspot server profiles');
      }
      
      // 7. Optionally remove hotspot-related IP pools
      if (deleteIpPools) {
        _log.d('Removing hotspot IP pools...');
        final pools = await getIpPools();
        final poolIds = pools
            .where((r) => r['type'] != 'done')
            .where((p) => p['name']?.contains('hs-pool') == true || p['name']?.contains('hotspot') == true)
            .map((p) => p['.id'])
            .whereType<String>()
            .toList();
        for (final id in poolIds) {
          await sendCommand(['/ip/pool/remove', '=.id=$id']);
        }
        _log.i('Removed ${poolIds.length} IP pools');
      }
      
      _log.i('HotSpot reset completed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('HotSpot reset failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Sanitize time value for RouterOS (e.g., "1h 2m" -> "1h2m")
  String _sanitizeTimeValue(String value) {
    // Remove spaces between time units
    return value.replaceAll(' ', '');
  }
  
  /// Sanitize bytes value for RouterOS (e.g., "1.5 G" -> "1536M", "500M" -> "500M")
  String _sanitizeBytesValue(String value) {
    // Remove spaces
    var sanitized = value.replaceAll(' ', '');
    
    // Handle decimal values (e.g., "1.5G" -> "1536M")
    final decimalPattern = RegExp(r'^(\d+)\.(\d+)([KMG])$', caseSensitive: false);
    final match = decimalPattern.firstMatch(sanitized);
    if (match != null) {
      final whole = int.parse(match.group(1)!);
      final decimal = int.parse(match.group(2)!);
      final unit = match.group(3)!.toUpperCase();
      
      // Convert to smaller unit
      if (unit == 'G') {
        // 1.5G = 1536M (1.5 * 1024)
        final totalMB = (whole * 1024) + (decimal * 1024 ~/ 10);
        sanitized = '${totalMB}M';
      } else if (unit == 'M') {
        // 1.5M = 1536K
        final totalKB = (whole * 1024) + (decimal * 1024 ~/ 10);
        sanitized = '${totalKB}K';
      }
    }
    
    return sanitized;
  }
}
