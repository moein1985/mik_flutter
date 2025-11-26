import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String host, int port, String username, String password);
  Future<void> disconnect();
  RouterOSClient? get client;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  RouterOSClient? _client;

  @override
  Future<bool> login(String host, int port, String username, String password) async {
    try {
      _client = RouterOSClient(host: host, port: port);
      await _client!.connect();
      final success = await _client!.login(username, password);
      
      if (!success) {
        await _client!.disconnect();
        throw AuthenticationException('Invalid credentials');
      }
      
      return true;
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
  }

  RouterOSClient? get client => _client;
}
