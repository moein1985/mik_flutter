class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => message;
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

/// Exception thrown when SSL/TLS handshake fails
/// Usually indicates missing or invalid certificate on RouterOS
class SslCertificateException implements Exception {
  final String message;
  final bool noCertificate;
  
  SslCertificateException(this.message, {this.noCertificate = false});
  
  @override
  String toString() => message;
}
