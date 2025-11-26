import 'package:equatable/equatable.dart';

class RouterSession extends Equatable {
  final String host;
  final int port;
  final String username;
  final DateTime connectedAt;

  const RouterSession({
    required this.host,
    required this.port,
    required this.username,
    required this.connectedAt,
  });

  @override
  List<Object> get props => [host, port, username, connectedAt];
}
