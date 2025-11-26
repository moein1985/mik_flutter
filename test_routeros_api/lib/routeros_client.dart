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

  /// Connect to RouterOS device
  Future<void> connect() async {
    try {
      print('🔌 Connecting to $host:$port...');
      _socket = await Socket.connect(host, port, timeout: Duration(seconds: 10));
      _isConnected = true;
      print('✅ Connected successfully!');

      // Listen to incoming data
      _socket!.listen(
        (data) {
          _buffer.addAll(data);
          _processBuffer();
        },
        onError: (error) {
          print('❌ Socket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('🔌 Connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      print('❌ Connection failed: $e');
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
      print('👋 Disconnected');
    }
  }

  /// Send a command to RouterOS
  Future<List<Map<String, String>>> sendCommand(List<String> words) async {
    if (!_isConnected || _socket == null) {
      throw Exception('Not connected to RouterOS');
    }

    print('\n📤 Sending command: ${words.join(" ")}');

    // Clear previous response data
    _responseData.clear();
    _currentReply = {};

    // Encode and send
    final encoded = RouterOSProtocol.encodeSentence(words);
    _socket!.add(encoded);

    // Wait for response with a new completer
    final completer = Completer<List<Map<String, String>>>();
    _activeCompleter = completer;
    
    return await completer.future.timeout(
      Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Response timeout');
      },
    );
  }

  /// Login to RouterOS
  Future<bool> login(String username, String password) async {
    print('\n🔐 Attempting login...');
    print('   Username: $username');

    try {
      // Modern RouterOS (v6.43+) uses simple login
      final response = await sendCommand([
        '/login',
        '=name=$username',
        '=password=$password',
      ]);

      // Check if login was successful
      final success = response.isNotEmpty && 
                     response.any((r) => r['type'] == 'done');

      if (success) {
        print('✅ Login successful!');
      } else {
        print('❌ Login failed');
      }

      return success;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  void _processBuffer() {
    while (_buffer.isNotEmpty) {
      try {
        // Try to decode length
        final (length, bytesRead) = RouterOSProtocol.decodeLength(_buffer);

        // Check if we have the full word
        if (bytesRead + length > _buffer.length) {
          // Not enough data yet, wait for more
          return;
        }

        // Extract word
        if (length == 0) {
          // End of sentence - empty word
          _buffer.removeRange(0, bytesRead);
          
          // Complete the response if we have !done or !trap
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

        // Remove processed bytes
        _buffer.removeRange(0, bytesRead + length);

        // Parse word
        _handleWord(word);
      } catch (e) {
        // If we can't decode, wait for more data
        return;
      }
    }
  }

  void _handleWord(String word) {
    print('📥 Received: $word');

    if (word.startsWith('!')) {
      // Control word
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
      // Attribute: =key=value
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
