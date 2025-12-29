import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CancellationFailure extends Failure {
  const CancellationFailure() : super('Operation cancelled by user.');
}

/// Failure when SSL certificate is missing or invalid on RouterOS
class SslCertificateFailure extends Failure {
  final bool noCertificate;
  
  const SslCertificateFailure(super.message, {this.noCertificate = false});
  
  @override
  List<Object> get props => [message, noCertificate];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
