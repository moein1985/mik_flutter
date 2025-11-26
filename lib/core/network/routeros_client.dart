import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'routeros_protocol.dart';

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
      throw Exception('Not connected to RouterOS');
    }

    _responseData.clear();
    _currentReply = {};

    final encoded = RouterOSProtocol.encodeSentence(words);
    _socket!.add(encoded);

    final completer = Completer<List<Map<String, String>>>();
    _activeCompleter = completer;
    
    return await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Response timeout');
      },
    );
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
}
