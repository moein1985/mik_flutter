import 'package:equatable/equatable.dart';

class RouterCredentials extends Equatable {
  final String host;
  final int port;
  final String username;
  final String password;

  const RouterCredentials({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [host, port, username, password];
}
