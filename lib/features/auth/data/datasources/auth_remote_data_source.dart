import '../../../../core/network/routeros_client_v2.dart';
import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String host, int port, String username, String password, {bool useSsl = false});
  Future<void> disconnect();
  /// RouterOSClientV2 for streaming operations (logs, ping, traceroute)
  RouterOSClientV2? get client;
  /// RouterOSClient for non-streaming operations (all other features)
  RouterOSClient? get legacyClient;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  RouterOSClientV2? _client;
  RouterOSClient? _legacyClient;

  @override
  Future<bool> login(String host, int port, String username, String password, {bool useSsl = false}) async {
    try {
      // Create both clients
      _client = RouterOSClientV2(host: host, port: port, useSsl: useSsl);
      _legacyClient = RouterOSClient(host: host, port: port, useSsl: useSsl);
      
      // Connect and login with V2 client (for streaming)
      await _client!.connect();
      final success = await _client!.login(username, password);
      
      if (!success) {
        await _client!.disconnect();
        _client = null;
        _legacyClient = null;
        throw AuthenticationException('Invalid credentials');
      }
      
      // Connect legacy client (for non-streaming) and login
      await _legacyClient!.connect();
      final legacySuccess = await _legacyClient!.login(username, password);
      
      if (!legacySuccess) {
        await _client!.disconnect();
        await _legacyClient!.disconnect();
        _client = null;
        _legacyClient = null;
        throw AuthenticationException('Invalid credentials for legacy client');
      }
      
      return true;
    } on SslCertificateException {
      // Re-throw SSL certificate exceptions as-is
      rethrow;
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ConnectionException('Failed to connect to router: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    if (_client != null) {
      await _client!.disconnect();
      _client = null;
    }
    if (_legacyClient != null) {
      await _legacyClient!.disconnect();
      _legacyClient = null;
    }
  }

  @override
  RouterOSClientV2? get client => _client;
  
  @override
  RouterOSClient? get legacyClient => _legacyClient;
}
