import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'routeros_protocol.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';

final _log = AppLogger.tag('RouterOSClient');

class RouterOSClient {
  final String host;
  final int port;
  final bool useSsl;
  Socket? _socket;
  final List<int> _buffer = [];
  bool _isConnected = false;

  final List<Map<String, String>> _responseData = [];
  Map<String, String> _currentReply = {};
  Completer<List<Map<String, String>>>? _activeCompleter;

  // Streaming support
  String? _activeStreamingTag; // Track which command is streaming
  final Map<String, StreamController<Map<String, String>>> _streamControllers = {};
  final Set<String> _cancelledTags = {}; // Tags that have been cancelled (ignore their done/trap)

  RouterOSClient({
    required this.host,
    required this.port,
    this.useSsl = false,
  });

  bool get isConnected => _isConnected;

  /// Connect to RouterOS device
  /// Uses SecureSocket for SSL connections (port 8729) or regular Socket (port 8728)
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      if (useSsl) {
        // SSL connection (API-SSL, typically port 8729)
        _log.i('Connecting with SSL to $host:$port');
        // Wrap in timeout to handle cases where SSL handshake hangs
        // (e.g., connecting to non-SSL port with SSL enabled)
        _socket = await SecureSocket.connect(
          host,
          port,
          timeout: const Duration(seconds: 10),
          onBadCertificate: (X509Certificate cert) {
            // Accept self-signed certificates (common in RouterOS)
            _log.w('Accepting self-signed certificate: ${cert.subject}');
            return true;
          },
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException(
              'SSL connection timed out. This may happen if you are trying to connect '
              'with SSL to a non-SSL port, or if the router is not responding.',
            );
          },
        );
      } else {
        // Plain connection (API, typically port 8728)
        _log.i('Connecting without SSL to $host:$port');
        _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 10));
      }
      
      _isConnected = true;
      _log.i('Connected successfully (SSL: $useSsl)');

      _socket!.listen(
        (data) {
          _buffer.addAll(data);
          _processBuffer();
        },
        onError: (error) {
          _isConnected = false;
          _activeCompleter?.completeError(error);
          
          // Close all active streams on connection error
          for (final controller in _streamControllers.values) {
            if (!controller.isClosed) {
              controller.addError(error);
              controller.close();
            }
          }
          _streamControllers.clear();
          _activeStreamingTag = null;
        },
        onDone: () {
          _isConnected = false;
          
          // Close all active streams when connection closes
          for (final controller in _streamControllers.values) {
            if (!controller.isClosed) {
              controller.close();
            }
          }
          _streamControllers.clear();
          _activeStreamingTag = null;
        },
      );
    } catch (e) {
      _log.e('Connection failed (SSL: $useSsl)', error: e);
      _isConnected = false;
      
      // Check for timeout (usually means wrong port for SSL)
      if (useSsl && e is TimeoutException) {
        throw SslCertificateException(
          'SSL connection timed out. This may happen if you are trying to connect '
          'with SSL enabled to a non-SSL port. Please check your port number or disable SSL.',
          noCertificate: false,
        );
      }
      
      // Check for SSL handshake failure (usually means no certificate on router)
      if (useSsl && e is HandshakeException) {
        final errorMsg = e.toString();
        if (errorMsg.contains('HANDSHAKE_FAILURE') || 
            errorMsg.contains('CERTIFICATE') ||
            errorMsg.contains('handshake')) {
          throw SslCertificateException(
            'SSL handshake failed. The router may not have a certificate configured for API-SSL. '
            'Please go to IP → Services and configure a certificate for api-ssl, or use plain API connection.',
            noCertificate: true,
          );
        }
      }
      
      rethrow;
    }
  }

  /// Disconnect from RouterOS device
  Future<void> disconnect() async {
    // Close all active streams
    for (final controller in _streamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _streamControllers.clear();
    _activeStreamingTag = null;
    
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Filter out protocol messages (done, trap, fatal) from response
  /// Note: 're' is NOT filtered as it contains actual data
  List<Map<String, String>> _filterProtocolMessages(List<Map<String, String>> response) {
    return response.where((item) {
      final type = item['type'];
      // Keep items with no type, or type='re' (actual data)
      // Remove type='done', 'trap', 'fatal' (protocol messages)
      return type == null || type == 're' || (type != 'done' && type != 'trap' && type != 'fatal');
    }).toList();
  }

  /// Send a command to RouterOS
  /// [timeout] - optional timeout duration, defaults to 10 seconds
  Future<List<Map<String, String>>> sendCommand(
    List<String> words, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
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
        timeout,
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
    final response = await sendCommand(['/system/resource/print']);
    return _filterProtocolMessages(response);
  }

  /// Get all interfaces
  Future<List<Map<String, String>>> getInterfaces() async {
    final response = await sendCommand(['/interface/print']);
    return _filterProtocolMessages(response);
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

  /// Monitor interface traffic
  /// Returns real-time traffic data for the specified interface
  /// Response includes: rx-bits-per-second, tx-bits-per-second, rx-packets-per-second, tx-packets-per-second
  Future<Map<String, String>> monitorTraffic(String interfaceName) async {
    try {
      final response = await sendCommand(
        [
          '/interface/monitor-traffic',
          '=interface=$interfaceName',
          '=once=',
        ],
        timeout: const Duration(seconds: 5),
      );
      
      // Find the data response (not 'done' or 'trap')
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

  /// Get all IP addresses
  Future<List<Map<String, String>>> getIpAddresses() async {
    final response = await sendCommand(['/ip/address/print']);
    return _filterProtocolMessages(response);
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

  /// Get DHCP leases
  Future<List<Map<String, String>>> getDhcpLeases() async {
    final response = await sendCommand(['/ip/dhcp-server/lease/print']);
    return _filterProtocolMessages(response);
  }

  /// Get all IP pools
  Future<List<Map<String, String>>> getIpPools() async {
    final response = await sendCommand(['/ip/pool/print']);
    return _filterProtocolMessages(response);
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
          
          if (_responseData.isNotEmpty) {
            final lastType = _responseData.last['type'];
            
            // Check if this is a response from a cancelled tag (ignore it)
            if (_cancelledTags.isNotEmpty && (lastType == 'done' || lastType == 'trap')) {
              // This is likely a response from a cancelled streaming operation
              // Just clear it and remove from cancelled set
              _cancelledTags.clear();
              _responseData.clear();
              continue;
            }
            
            // Check if we have an active stream
            if (_activeStreamingTag != null && _streamControllers.containsKey(_activeStreamingTag)) {
              final controller = _streamControllers[_activeStreamingTag];
              
              // Emit data responses (!re) to stream
              for (final item in _responseData) {
                if (item['type'] == 're') {
                  controller?.add(item);
                }
              }
              
              // If done or trap, close the stream
              if (lastType == 'done' || lastType == 'trap') {
                if (lastType == 'trap') {
                  final errorMsg = _responseData.last['message'] ?? 'Unknown error';
                  controller?.addError(Exception(errorMsg));
                }
                controller?.close();
                _streamControllers.remove(_activeStreamingTag);
                _activeStreamingTag = null;
              }
              // Clear response data after processing for streaming
              _responseData.clear();
            } 
            // Otherwise use the regular completer pattern
            else if (_activeCompleter != null) {
              if (lastType == 'done' || lastType == 'trap') {
                if (!_activeCompleter!.isCompleted) {
                  _activeCompleter!.complete(List.from(_responseData));
                  _responseData.clear();
                  _activeCompleter = null;
                }
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
        }
        // Start a new reply for trap - error details will follow
        _currentReply = {'type': 'trap'};
      } else if (word == '!re') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
        }
        _currentReply = {'type': 're'};
      } else if (word == '!fatal') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
        }
        _currentReply = {'type': 'fatal'};
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
    final response = await sendCommand(['/ip/hotspot/print']);
    return _filterProtocolMessages(response);
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
    final response = await sendCommand(['/ip/hotspot/user/print']);
    return _filterProtocolMessages(response);
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
    final response = await sendCommand(['/ip/hotspot/active/print']);
    return _filterProtocolMessages(response);
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
    final response = await sendCommand(['/ip/hotspot/ip-binding/print']);
    return _filterProtocolMessages(response);
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
    final response = await sendCommand(['/ip/hotspot/host/print']);
    return _filterProtocolMessages(response);
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
    final response = await sendCommand(['/ip/hotspot/walled-garden/print']);
    return _filterProtocolMessages(response);
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
    final response = await sendCommand(['/ip/hotspot/walled-garden/ip/print']);
    return _filterProtocolMessages(response);
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
  
  /// Sanitize time value for RouterOS
  /// Converts formats like "1D", "2H", "30M" to RouterOS format "1d 00:00:00", "02:00:00", "00:30:00"
  /// Also accepts "1d", "2h", "30m" (lowercase)
  String _sanitizeTimeValue(String value) {
    // Remove spaces and convert to lowercase
    var sanitized = value.replaceAll(' ', '').toLowerCase();
    
    // Parse days, hours, minutes, seconds
    int days = 0;
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    
    // Match patterns like "1d", "2h", "30m", "45s" or combinations like "1d2h30m"
    final dayMatch = RegExp(r'(\d+)d').firstMatch(sanitized);
    final hourMatch = RegExp(r'(\d+)h').firstMatch(sanitized);
    final minMatch = RegExp(r'(\d+)m(?!s)').firstMatch(sanitized); // m but not ms
    final secMatch = RegExp(r'(\d+)s').firstMatch(sanitized);
    
    if (dayMatch != null) days = int.parse(dayMatch.group(1)!);
    if (hourMatch != null) hours = int.parse(hourMatch.group(1)!);
    if (minMatch != null) minutes = int.parse(minMatch.group(1)!);
    if (secMatch != null) seconds = int.parse(secMatch.group(1)!);
    
    // If we parsed something, format it for RouterOS
    if (days > 0 || hours > 0 || minutes > 0 || seconds > 0) {
      // Format: Xd HH:MM:SS or just HH:MM:SS
      final timeStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      if (days > 0) {
        return '${days}d $timeStr';
      }
      return timeStr;
    }
    
    // If no pattern matched, return as-is (might be already in correct format)
    return sanitized;
  }
  
  /// Sanitize bytes value for RouterOS
  /// Converts formats like "1G", "500M", "1.5G" to raw bytes
  /// RouterOS expects raw byte values, not suffixed values
  String _sanitizeBytesValue(String value) {
    // Remove spaces and convert to lowercase
    var sanitized = value.replaceAll(' ', '').toLowerCase();
    
    // Try to parse as a number with suffix
    final pattern = RegExp(r'^(\d+(?:\.\d+)?)([kmgt]?)$', caseSensitive: false);
    final match = pattern.firstMatch(sanitized);
    
    if (match != null) {
      final numStr = match.group(1)!;
      final unit = match.group(2)?.toLowerCase() ?? '';
      final num = double.parse(numStr);
      
      int bytes;
      switch (unit) {
        case 'k':
          bytes = (num * 1024).round();
          break;
        case 'm':
          bytes = (num * 1024 * 1024).round();
          break;
        case 'g':
          bytes = (num * 1024 * 1024 * 1024).round();
          break;
        case 't':
          bytes = (num * 1024 * 1024 * 1024 * 1024).round();
          break;
        default:
          bytes = num.round();
      }
      
      return bytes.toString();
    }
    
    // If no pattern matched, return as-is
    return sanitized;
  }

  // ==================== FIREWALL METHODS ====================

  /// Get firewall rules by path
  /// [path] should be like '/ip/firewall/nat', '/ip/firewall/filter', etc.
  Future<List<Map<String, String>>> getFirewallRules(String path) async {
    _log.d('Getting firewall rules from: $path');
    final response = await sendCommand(['$path/print']);
    final filtered = _filterProtocolMessages(response);
    _log.d('Got ${filtered.length} firewall rules');
    return filtered;
  }

  /// Enable a firewall rule
  Future<bool> enableFirewallRule(String path, String id) async {
    try {
      _log.d('Enabling firewall rule: $path $id');
      final response = await sendCommand([
        '$path/enable',
        '=.id=$id',
      ]);
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to enable rule: $errorMessage');
        throw Exception(errorMessage);
      }
      
      _log.i('Rule enabled successfully: $id');
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to enable firewall rule', error: e);
      rethrow;
    }
  }

  /// Disable a firewall rule
  Future<bool> disableFirewallRule(String path, String id) async {
    try {
      _log.d('Disabling firewall rule: $path $id');
      final response = await sendCommand([
        '$path/disable',
        '=.id=$id',
      ]);
      
      // Check for trap (error)
      final trap = response.firstWhere(
        (r) => r['type'] == 'trap',
        orElse: () => {},
      );
      if (trap.isNotEmpty) {
        final errorMessage = trap['message'] ?? 'Unknown error';
        _log.e('Failed to disable rule: $errorMessage');
        throw Exception(errorMessage);
      }
      
      _log.i('Rule disabled successfully: $id');
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      _log.e('Failed to disable firewall rule', error: e);
      rethrow;
    }
  }

  /// Get unique address list names only (lightweight query)
  /// Returns only the list names without all the addresses
  Future<List<String>> getAddressListNames() async {
    _log.d('Getting address list names only');
    // Use proplist to get only the 'list' field - much faster for large lists
    final response = await sendCommand(
      ['/ip/firewall/address-list/print', '=.proplist=list'],
      timeout: const Duration(seconds: 30),
    );
    
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

  /// Get address list entries filtered by list name
  /// [listName] - the name of the address list to filter by
  Future<List<Map<String, String>>> getAddressListByName(String listName) async {
    _log.d('Getting address list entries for: $listName');
    final response = await sendCommand(
      ['/ip/firewall/address-list/print', '?list=$listName'],
      timeout: const Duration(seconds: 60),
    );
    final filtered = _filterProtocolMessages(response);
    _log.d('Got ${filtered.length} entries for list: $listName');
    return filtered;
  }

  /// Get address list entries with pagination
  /// [offset] - starting position
  /// [limit] - number of items to fetch
  Future<List<Map<String, String>>> getAddressListPaginated({
    int offset = 0,
    int limit = 100,
  }) async {
    _log.d('Getting address list with pagination: offset=$offset, limit=$limit');
    final response = await sendCommand(
      [
        '/ip/firewall/address-list/print',
        '=.proplist=.id,list,address,disabled,dynamic,creation-time,comment',
        '=from=$offset',
        '=count=$limit',
      ],
      timeout: const Duration(seconds: 30),
    );
    final filtered = _filterProtocolMessages(response);
    _log.d('Got ${filtered.length} address list entries');
    return filtered;
  }

  /// Get total count of address list entries
  Future<int> getAddressListCount() async {
    _log.d('Getting address list count');
    final response = await sendCommand(
      ['/ip/firewall/address-list/print', '=count-only='],
      timeout: const Duration(seconds: 30),
    );
    
    final countStr = response.firstWhere(
      (r) => r['type'] == 'done',
      orElse: () => {},
    )['ret'];
    
    final count = int.tryParse(countStr ?? '0') ?? 0;
    _log.d('Total address list count: $count');
    return count;
  }

  // ==================== DIAGNOSTIC TOOLS ====================

  /// Perform ping operation
  /// Returns real-time ping results
  Future<List<Map<String, String>>> ping({
    required String address,
    int count = 4,
    int interval = 1,
    int timeout = 1000,
  }) async {
    try {
      _log.d('Starting ping to: $address (count: $count)');
      final response = await sendCommand([
        '/tool/ping',
        '=address=$address',
        '=count=$count',
        '=interval=$interval',
      ], timeout: Duration(seconds: (timeout ~/ 1000 + count * 2).clamp(10, 120)));

      _log.d('Ping completed, got ${response.length} responses');
      return response;
    } catch (e) {
      _log.e('Ping failed for $address', error: e);
      rethrow;
    }
  }

  /// Perform streaming ping operation
  /// Returns a stream that emits ping results in real-time as packets are sent/received
  Stream<Map<String, String>> pingStream({
    required String address,
    int count = 100,
    int interval = 1,
  }) {
    final tag = 'ping_${DateTime.now().millisecondsSinceEpoch}';
    final controller = StreamController<Map<String, String>>();
    
    _streamControllers[tag] = controller;
    _activeStreamingTag = tag;

    _log.i('Starting streaming ping to: $address');

    // Send ping command
    final encoded = RouterOSProtocol.encodeSentence([
      '/tool/ping',
      '=address=$address',
      '=count=$count',
      '=interval=$interval',
    ]);
    
    if (_socket != null && _isConnected) {
      _socket!.add(encoded);
    } else {
      controller.addError(Exception('Not connected to RouterOS'));
      controller.close();
      _streamControllers.remove(tag);
      _activeStreamingTag = null;
    }

    return controller.stream;
  }

  /// Stop an active streaming operation
  void stopStreaming() {
    if (_activeStreamingTag != null && _streamControllers.containsKey(_activeStreamingTag)) {
      _log.i('Stopping streaming operation: $_activeStreamingTag');
      
      // Add to cancelled tags so we ignore the /cancel response
      _cancelledTags.add(_activeStreamingTag!);
      
      // Close the stream first
      _streamControllers[_activeStreamingTag]?.close();
      _streamControllers.remove(_activeStreamingTag);
      _activeStreamingTag = null;
      _responseData.clear();
      
      // Send cancel command
      if (_socket != null && _isConnected) {
        final encoded = RouterOSProtocol.encodeSentence(['/cancel']);
        _socket!.add(encoded);
      }
    }
  }

  /// Perform traceroute operation
  /// Returns hop-by-hop routing information
  Future<List<Map<String, String>>> traceroute({
    required String address,
    int maxHops = 30,
    int timeout = 1000,
  }) async {
    try {
      _log.d('Starting traceroute to: $address (max-hops: $maxHops)');
      
      // Note: count parameter makes RouterOS repeat the entire traceroute that many times
      // We'll filter to only show the first section in the parser
      final response = await sendCommand([
        '/tool/traceroute',
        '=address=$address',
        '=count=3',  // Run traceroute 3 times for better statistics per hop
      ], timeout: Duration(seconds: (maxHops * 3 + 30).clamp(60, 180)));

      _log.d('Traceroute completed, got ${response.length} responses');
      return response;
    } catch (e) {
      _log.e('Traceroute failed for $address', error: e);
      rethrow;
    }
  }

  /// Perform streaming traceroute operation
  /// Returns a stream that emits hop information in real-time as each hop is discovered
  Stream<Map<String, String>> tracerouteStream({
    required String address,
    int maxHops = 30,
  }) {
    final tag = 'traceroute_${DateTime.now().millisecondsSinceEpoch}';
    final controller = StreamController<Map<String, String>>();
    
    _streamControllers[tag] = controller;
    _activeStreamingTag = tag;

    _log.i('Starting streaming traceroute to: $address');

    // Send traceroute command
    final encoded = RouterOSProtocol.encodeSentence([
      '/tool/traceroute',
      '=address=$address',
      '=count=3',  // Run 3 probes per hop for better statistics
    ]);
    
    if (_socket != null && _isConnected) {
      _socket!.add(encoded);
    } else {
      controller.addError(Exception('Not connected to RouterOS'));
      controller.close();
      _streamControllers.remove(tag);
      _activeStreamingTag = null;
    }

    return controller.stream;
  }

  /// Perform DNS lookup
  /// Resolves domain names to IP addresses
  Future<List<Map<String, String>>> dnsLookup({
    required String name,
    int timeout = 5000,
  }) async {
    try {
      _log.d('Starting DNS lookup for: $name');
      final response = await sendCommand([
        '/tool/dns-lookup',
        '=name=$name',
      ], timeout: Duration(seconds: (timeout ~/ 1000 + 5).clamp(10, 60)));

      _log.d('DNS lookup completed, got ${response.length} responses');
      return response;
    } catch (e) {
      _log.e('DNS lookup failed for $name', error: e);
      rethrow;
    }
  }

  /// Get all simple queues
  Future<List<Map<String, String>>> getSimpleQueues() async {
    try {
      _log.d('Getting simple queues');
      final response = await sendCommand(['/queue/simple/print']);
      // Filter out protocol messages (done, trap, re, fatal)
      final queues = response.where((item) {
        final type = item['type'];
        return type == null || (type != 'done' && type != 'trap' && type != 're' && type != 'fatal');
      }).toList();
      _log.d('Got ${queues.length} queues');
      return queues;
    } catch (e) {
      _log.e('Failed to get simple queues', error: e);
      rethrow;
    }
  }

  /// Add a new simple queue
  Future<Map<String, String>> addSimpleQueue(Map<String, String> params) async {
    try {
      _log.d('Adding simple queue with params: $params');
      final command = ['/queue/simple/add'];
      params.forEach((key, value) {
        command.add('=$key=$value');
      });

      final response = await sendCommand(command);
      _log.d('Queue added successfully');
      return response.isNotEmpty ? response.first : {};
    } catch (e) {
      _log.e('Failed to add simple queue', error: e);
      rethrow;
    }
  }

  /// Update an existing simple queue
  Future<void> updateSimpleQueue(String queueId, Map<String, String> params) async {
    try {
      _log.d('Updating simple queue $queueId with params: $params');
      final command = ['/queue/simple/set', '=.id=$queueId'];
      params.forEach((key, value) {
        command.add('=$key=$value');
      });

      await sendCommand(command);
      _log.d('Queue updated successfully');
    } catch (e) {
      _log.e('Failed to update simple queue $queueId', error: e);
      rethrow;
    }
  }

  /// Delete a simple queue
  Future<void> deleteSimpleQueue(String queueId) async {
    try {
      _log.d('Deleting simple queue $queueId');
      await sendCommand([
        '/queue/simple/remove',
        '=.id=$queueId',
      ]);
      _log.d('Queue deleted successfully');
    } catch (e) {
      _log.e('Failed to delete simple queue $queueId', error: e);
      rethrow;
    }
  }

  /// Enable a simple queue
  Future<void> enableSimpleQueue(String queueId) async {
    try {
      _log.d('Enabling simple queue $queueId');
      await sendCommand([
        '/queue/simple/enable',
        '=.id=$queueId',
      ]);
      _log.d('Queue enabled successfully');
    } catch (e) {
      _log.e('Failed to enable simple queue $queueId', error: e);
      rethrow;
    }
  }

  /// Disable a simple queue
  Future<void> disableSimpleQueue(String queueId) async {
    try {
      _log.d('Disabling simple queue $queueId');
      await sendCommand([
        '/queue/simple/disable',
        '=.id=$queueId',
      ]);
      _log.d('Queue disabled successfully');
    } catch (e) {
      _log.e('Failed to disable simple queue $queueId', error: e);
      rethrow;
    }
  }

  // ===== WIRELESS METHODS =====

  /// Get all wireless interfaces
  Future<List<Map<String, String>>> getWirelessInterfaces() async {
    try {
      _log.d('Getting wireless interfaces');
      final result = await sendCommand(['/interface/wireless/print']);
      final filtered = _filterProtocolMessages(result);
      _log.d('Retrieved ${filtered.length} wireless interfaces');
      return filtered;
    } catch (e) {
      _log.e('Failed to get wireless interfaces', error: e);
      rethrow;
    }
  }

  /// Enable a wireless interface
  Future<void> enableWirelessInterface(String interfaceId) async {
    try {
      _log.d('Enabling wireless interface $interfaceId');
      await sendCommand([
        '/interface/wireless/enable',
        '=.id=$interfaceId',
      ]);
      _log.d('Wireless interface enabled successfully');
    } catch (e) {
      _log.e('Failed to enable wireless interface $interfaceId', error: e);
      rethrow;
    }
  }

  /// Disable a wireless interface
  Future<void> disableWirelessInterface(String interfaceId) async {
    try {
      _log.d('Disabling wireless interface $interfaceId');
      await sendCommand([
        '/interface/wireless/disable',
        '=.id=$interfaceId',
      ]);
      _log.d('Wireless interface disabled successfully');
    } catch (e) {
      _log.e('Failed to disable wireless interface $interfaceId', error: e);
      rethrow;
    }
  }

  /// Update a wireless interface
  Future<void> updateWirelessInterface(String interfaceId, Map<String, dynamic> data) async {
    try {
      _log.d('Updating wireless interface $interfaceId');
      final command = ['/interface/wireless/set', '=.id=$interfaceId'];
      data.forEach((key, value) {
        command.add('=$key=$value');
      });
      await sendCommand(command);
      _log.d('Wireless interface updated successfully');
    } catch (e) {
      _log.e('Failed to update wireless interface $interfaceId', error: e);
      rethrow;
    }
  }

  /// Get wireless registration table (connected clients)
  Future<List<Map<String, String>>> getWirelessRegistrations() async {
    try {
      _log.d('Getting wireless registrations');
      final result = await sendCommand(['/interface/wireless/registration-table/print']);
      final filtered = _filterProtocolMessages(result);
      _log.d('Retrieved ${filtered.length} wireless registrations');
      return filtered;
    } catch (e) {
      _log.e('Failed to get wireless registrations', error: e);
      rethrow;
    }
  }

  /// Disconnect a wireless client
  Future<void> disconnectWirelessClient(String macAddress, String interfaceName) async {
    try {
      _log.d('Disconnecting wireless client $macAddress from $interfaceName');
      await sendCommand([
        '/interface/wireless/registration-table/remove',
        '=.id=$macAddress@$interfaceName',
      ]);
      _log.d('Wireless client disconnected successfully');
    } catch (e) {
      _log.e('Failed to disconnect wireless client $macAddress', error: e);
      rethrow;
    }
  }

  /// Get wireless security profiles
  Future<List<Map<String, String>>> getWirelessSecurityProfiles() async {
    try {
      _log.d('Getting wireless security profiles');
      final result = await sendCommand(['/interface/wireless/security-profiles/print']);
      final filtered = _filterProtocolMessages(result);
      _log.d('Retrieved ${filtered.length} wireless security profiles');
      return filtered;
    } catch (e) {
      _log.e('Failed to get wireless security profiles', error: e);
      rethrow;
    }
  }

  /// Create a wireless security profile
  Future<void> createWirelessSecurityProfile(Map<String, dynamic> data) async {
    try {
      _log.d('Creating wireless security profile');
      final command = ['/interface/wireless/security-profiles/add'];
      data.forEach((key, value) {
        command.add('=$key=$value');
      });
      await sendCommand(command);
      _log.d('Wireless security profile created successfully');
    } catch (e) {
      _log.e('Failed to create wireless security profile', error: e);
      rethrow;
    }
  }

  /// Update a wireless security profile
  Future<void> updateWirelessSecurityProfile(String profileId, Map<String, dynamic> data) async {
    try {
      _log.d('Updating wireless security profile $profileId');
      final command = ['/interface/wireless/security-profiles/set', '=.id=$profileId'];
      data.forEach((key, value) {
        command.add('=$key=$value');
      });
      await sendCommand(command);
      _log.d('Wireless security profile updated successfully');
    } catch (e) {
      _log.e('Failed to update wireless security profile $profileId', error: e);
      rethrow;
    }
  }

  /// Delete a wireless security profile
  Future<void> deleteWirelessSecurityProfile(String profileId) async {
    try {
      _log.d('Deleting wireless security profile $profileId');
      await sendCommand([
        '/interface/wireless/security-profiles/remove',
        '=.id=$profileId',
      ]);
      _log.d('Wireless security profile deleted successfully');
    } catch (e) {
      _log.e('Failed to delete wireless security profile $profileId', error: e);
      rethrow;
    }
  }

  /// Get wireless access list
  Future<List<Map<String, String>>> getWirelessAccessList() async {
    try {
      _log.d('Getting wireless access list');
      final result = await sendCommand(['/interface/wireless/access-list/print']);
      final filtered = _filterProtocolMessages(result);
      _log.d('Retrieved ${filtered.length} wireless access list entries');
      return filtered;
    } catch (e) {
      _log.e('Failed to get wireless access list', error: e);
      rethrow;
    }
  }

  /// Add to wireless access list
  Future<void> addToWirelessAccessList(Map<String, dynamic> data) async {
    try {
      _log.d('Adding to wireless access list');
      final command = ['/interface/wireless/access-list/add'];
      data.forEach((key, value) {
        command.add('=$key=$value');
      });
      await sendCommand(command);
      _log.d('Added to wireless access list successfully');
    } catch (e) {
      _log.e('Failed to add to wireless access list', error: e);
      rethrow;
    }
  }

  /// Remove from wireless access list
  Future<void> removeFromWirelessAccessList(String entryId) async {
    try {
      _log.d('Removing from wireless access list $entryId');
      await sendCommand([
        '/interface/wireless/access-list/remove',
        '=.id=$entryId',
      ]);
      _log.d('Removed from wireless access list successfully');
    } catch (e) {
      _log.e('Failed to remove from wireless access list $entryId', error: e);
      rethrow;
    }
  }

  /// Get system logs
  Future<List<Map<String, String>>> getLogs({
    int? count,
    String? topics,
    String? since,
    String? until,
  }) async {
    try {
      final command = ['/log/print'];
      if (count != null) {
        command.addAll(['count=$count']);
      }
      if (topics != null && topics.isNotEmpty) {
        command.addAll(['topics=$topics']);
      }
      if (since != null && since.isNotEmpty) {
        command.addAll(['since=$since']);
      }
      if (until != null && until.isNotEmpty) {
        command.addAll(['until=$until']);
      }

      final result = await sendCommand(command);
      final filtered = _filterProtocolMessages(result);
      _log.d('Retrieved ${filtered.length} log entries');
      return filtered;
    } catch (e) {
      _log.e('Failed to get logs', error: e);
      rethrow;
    }
  }

  /// Follow logs in real-time (streaming)
  /// Returns a stream that emits log entries as they appear in RouterOS
  Stream<Map<String, String>> followLogs({
    String? topics,
  }) {
    final tag = 'logs_${DateTime.now().millisecondsSinceEpoch}';
    final controller = StreamController<Map<String, String>>();
    
    _streamControllers[tag] = controller;
    _activeStreamingTag = tag;

    _log.i('Starting to follow logs${topics != null ? " (topics: $topics)" : ""}');

    // Send log follow-only command (only new logs, not existing ones)
    final command = [
      '/log/print',
      '=follow-only=',
    ];
    if (topics != null && topics.isNotEmpty) {
      command.add('=topics=$topics');
    }
    
    final encoded = RouterOSProtocol.encodeSentence(command);
    
    if (_socket != null && _isConnected) {
      _socket!.add(encoded);
    } else {
      controller.addError(Exception('Not connected to RouterOS'));
      controller.close();
      _streamControllers.remove(tag);
      _activeStreamingTag = null;
    }

    return controller.stream;
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      await sendCommand(['/log/warning/clear']);
      _log.d('Cleared all logs successfully');
    } catch (e) {
      _log.e('Failed to clear logs', error: e);
      rethrow;
    }
  }

  /// Search logs by text
  Future<List<Map<String, String>>> searchLogs({
    required String query,
    int? count,
    String? topics,
  }) async {
    try {
      final command = ['/log/print'];
      if (count != null) {
        command.addAll(['count=$count']);
      }
      if (topics != null && topics.isNotEmpty) {
        command.addAll(['topics=$topics']);
      }

      final result = await sendCommand(command);
      final filtered = _filterProtocolMessages(result);

      // Filter results containing the query
      final filteredResult = filtered.where((logEntry) {
        final message = logEntry['message'] ?? '';
        final topics = logEntry['topics'] ?? '';
        return message.toLowerCase().contains(query.toLowerCase()) ||
               topics.toLowerCase().contains(query.toLowerCase());
      }).toList();

      _log.d('Found ${filteredResult.length} log entries matching "$query"');
      return filteredResult;
    } catch (e) {
      _log.e('Failed to search logs', error: e);
      rethrow;
    }
  }

  /// Get list of backup files
  Future<List<Map<String, String>>> getBackups() async {
    try {
      _log.d('Getting backup files list');
      final response = await sendCommand(['/system/backup/print']);
      return _filterProtocolMessages(response);
    } catch (e) {
      _log.e('Failed to get backups', error: e);
      rethrow;
    }
  }

  /// Create a new backup
  Future<void> createBackup(String name) async {
    try {
      _log.d('Creating backup: $name');
      await sendCommand(['/system/backup/save', '=name=$name']);
    } catch (e) {
      _log.e('Failed to create backup', error: e);
      rethrow;
    }
  }

  /// Delete a backup file
  Future<void> deleteBackup(String name) async {
    try {
      _log.d('Deleting backup: $name');
      await sendCommand(['/system/backup/remove', '=name=$name']);
    } catch (e) {
      _log.e('Failed to delete backup', error: e);
      rethrow;
    }
  }

  /// Restore from backup
  Future<void> restoreBackup(String name) async {
    try {
      _log.d('Restoring from backup: $name');
      await sendCommand(['/system/backup/load', '=name=$name']);
    } catch (e) {
      _log.e('Failed to restore backup', error: e);
      rethrow;
    }
  }
}

