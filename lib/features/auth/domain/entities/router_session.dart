import 'package:equatable/equatable.dart';

class RouterSession extends Equatable {
  final String host;
  final int port;
  final String username;
  final DateTime connectedAt;
  final bool useSsl;

  const RouterSession({
    required this.host,
    required this.port,
    required this.username,
    required this.connectedAt,
    this.useSsl = false,
  });

  @override
  List<Object> get props => [host, port, username, connectedAt, useSsl];
}
