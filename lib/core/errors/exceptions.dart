class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
