import 'dart:io';
import 'dart:async';
import '../routeros_protocol.dart';
import '../../utils/logger.dart';
import '../../errors/exceptions.dart';

final _log = AppLogger.tag('RouterOSBaseClient');

/// Base RouterOS client with connection management and core functionality
abstract class RouterOSBaseClient {
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
  String? _activeStreamingTag;
  final Map<String, StreamController<Map<String, String>>> _streamControllers = {};
  final Set<String> _cancelledTags = {};

  RouterOSBaseClient({
    required this.host,
    required this.port,
    this.useSsl = false,
    Socket? existingSocket,
  }) {
    if (existingSocket != null) {
      _socket = existingSocket;
      _isConnected = true;
      _socket!.listen(_onData, onError: _onError, onDone: _onDone);
      _log.i('Using existing socket connection');
    }
  }

  bool get isConnected => _isConnected;

  Socket? get socket => _socket;

  /// Set an existing socket to use instead of creating a new connection
  void useExistingSocket(Socket socket) {
    if (_isConnected) {
      // Don't destroy if it's the same socket
      if (_socket == socket) return;
      _socket?.destroy();
    }
    _socket = socket;
    _isConnected = true;
    // Don't listen to the socket here - the main client already listens
    _log.i('Using existing socket connection');
  }

  /// Connect to RouterOS device
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      if (useSsl) {
        _log.i('Connecting with SSL to $host:$port');
        _socket = await SecureSocket.connect(
          host,
          port,
          timeout: const Duration(seconds: 10),
          onBadCertificate: (X509Certificate cert) {
            _log.w('Accepting self-signed certificate for $host');
            return true; // Accept self-signed certificates (common in RouterOS)
          },
        );
      } else {
        _log.i('Connecting to $host:$port');
        _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 10));
      }

      _isConnected = true;
      _socket!.listen(_onData, onError: _onError, onDone: _onDone);
      _log.i('Connected successfully');
    } catch (e) {
      _log.e('Connection failed', error: e);
      rethrow;
    }
  }

  /// Disconnect from RouterOS device
  Future<void> disconnect() async {
    if (!_isConnected) return;

    try {
      // Close all active streams
      for (final controller in _streamControllers.values) {
        controller.close();
      }
      _streamControllers.clear();
      _cancelledTags.clear();

      _socket?.destroy();
      _socket = null;
      _isConnected = false;
      _activeCompleter = null;
      _log.i('Disconnected');
    } catch (e) {
      _log.e('Disconnect failed', error: e);
    }
  }

  /// Send a command and wait for response
  Future<List<Map<String, String>>> sendCommand(
    List<String> words, {
    Duration? timeout,
  }) async {
    if (!_isConnected) {
      throw ConnectionException('Not connected to RouterOS device');
    }

    // Wait for any existing command to complete
    while (_activeCompleter != null) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    final completer = Completer<List<Map<String, String>>>();
    _activeCompleter = completer;

    try {
      // Encode and send the command
      final encoded = RouterOSProtocol.encodeSentence(words);
      _socket!.add(encoded);

      // Wait for response with timeout
      final response = await completer.future.timeout(
        timeout ?? const Duration(seconds: 30),
        onTimeout: () {
          _activeCompleter = null;
          throw ConnectionException('Command timeout');
        },
      );

      return response;
    } finally {
      _activeCompleter = null;
    }
  }

  /// Login to RouterOS
  Future<bool> login(String username, String password) async {
    try {
      // sendCommand completes successfully only when !done is received
      // If login fails, RouterOS sends !trap which causes an error
      await sendCommand([
        '/login',
        '=name=$username',
        '=password=$password',
      ]);

      // If we get here without error, login was successful
      return true;
    } catch (e) {
      _log.e('Login failed', error: e);
      return false;
    }
  }

  /// Start streaming command
  Future<Stream<Map<String, String>>> startStream(List<String> words) async {
    if (!_isConnected) {
      throw ConnectionException('Not connected to RouterOS device');
    }

    final tag = DateTime.now().millisecondsSinceEpoch.toString();
    final controller = StreamController<Map<String, String>>();
    _streamControllers[tag] = controller;
    _activeStreamingTag = tag;

    try {
      final streamWords = [...words, '.tag=$tag'];
      final encoded = RouterOSProtocol.encodeSentence(streamWords);
      _socket!.add(encoded);
    } catch (e) {
      _streamControllers.remove(tag);
      controller.close();
      rethrow;
    }

    return controller.stream;
  }

  /// Stop streaming command
  Future<void> stopStream(String tag) async {
    if (_streamControllers.containsKey(tag)) {
      try {
        // Send cancel command
        final cancelWords = ['/cancel', '=tag=$tag'];
        final encoded = RouterOSProtocol.encodeSentence(cancelWords);
        _socket!.add(encoded);

        // Wait a bit for cancel to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Close the stream
        _streamControllers[tag]?.close();
        _streamControllers.remove(tag);
        _cancelledTags.add(tag);

        if (_activeStreamingTag == tag) {
          _activeStreamingTag = null;
        }
      } catch (e) {
        _log.e('Failed to stop stream', error: e);
      }
    }
  }

  void _onData(List<int> data) {
    _buffer.addAll(data);

    while (_buffer.isNotEmpty) {
      final result = RouterOSProtocol.decode(_buffer);
      if (result == null) break; // Need more data

      final (words, bytesConsumed) = result;
      _buffer.removeRange(0, bytesConsumed);
      _processResponse(words);
    }
  }

  void _onError(Object error) {
    _log.e('Socket error', error: error);

    // Close all active streams
    for (final controller in _streamControllers.values) {
      controller.addError(error);
      controller.close();
    }
    _streamControllers.clear();
    _cancelledTags.clear();

    _activeCompleter?.completeError(error);
    _activeCompleter = null;
  }

  void _onDone() {
    _log.i('Socket closed');
    _isConnected = false;

    // Close all active streams
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    _cancelledTags.clear();

    _activeCompleter?.completeError('Connection closed');
    _activeCompleter = null;
  }

  void _processResponse(List<String> words) {
    for (final word in words) {
      if (word == '!done') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
        }
        _currentReply = {'type': 'done'};
        _responseData.add(_currentReply);
        _currentReply = {};
      } else if (word == '!trap') {
        if (_currentReply.isNotEmpty) {
          _responseData.add(_currentReply);
        }
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
      } else if (word.startsWith('.tag=')) {
        final tagValue = word.substring(5);
        _currentReply['.tag'] = tagValue;
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

    // Process completed responses
    _processCompletedResponses();
  }

  void _processCompletedResponses() {
    // Check if we have a 'done' response - this signals command completion
    final hasDone = _responseData.any((r) => r['type'] == 'done');
    final hasTrap = _responseData.any((r) => r['type'] == 'trap');
    final hasFatal = _responseData.any((r) => r['type'] == 'fatal');
    
    // For streaming, check if any response has the active tag
    if (_activeStreamingTag != null && _streamControllers.containsKey(_activeStreamingTag)) {
      final controller = _streamControllers[_activeStreamingTag]!;
      for (final response in _responseData) {
        final responseTag = response['.tag'];
        if (responseTag == _activeStreamingTag) {
          if (response['type'] == 'trap') {
            // For trap responses, emit error before closing
            final errorMsg = response['message'] ?? 'RouterOS streaming error';
            _log.e('Stream received trap: $errorMsg');
            controller.addError(errorMsg);
            controller.close();
            _streamControllers.remove(_activeStreamingTag);
            _activeStreamingTag = null;
          } else if (response['type'] == 'done') {
            // Normal completion
            controller.close();
            _streamControllers.remove(_activeStreamingTag);
            _activeStreamingTag = null;
          } else if (response['type'] != 'fatal') {
            // Regular data
            controller.add(response);
          }
        }
      }
      _responseData.clear();
      return;
    }
    
    // For regular commands, wait for 'done' or error
    if (hasDone || hasTrap || hasFatal) {
      final responses = _filterProtocolMessages(_responseData);
      _responseData.clear();
      
      if (hasTrap) {
        final trapMsg = _responseData.firstWhere(
          (r) => r['type'] == 'trap',
          orElse: () => {},
        );
        _activeCompleter?.completeError(trapMsg['message'] ?? 'RouterOS error');
      } else if (hasFatal) {
        _activeCompleter?.completeError('Fatal RouterOS error');
      } else {
        // Complete with data responses (even if empty for commands like login)
        _activeCompleter?.complete(responses);
      }
    }
  }

  List<Map<String, String>> _filterProtocolMessages(List<Map<String, String>> response) {
    return response.where((item) {
      final type = item['type'];
      return type != 'done' && type != 'trap' && type != 'fatal';
    }).toList();
  }
}