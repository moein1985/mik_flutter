import 'package:equatable/equatable.dart';

class RouterCredentials extends Equatable {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useSsl;

  const RouterCredentials({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.useSsl = false,
  });

  /// Copy with new values
  RouterCredentials copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    bool? useSsl,
  }) {
    return RouterCredentials(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      useSsl: useSsl ?? this.useSsl,
    );
  }

  @override
  List<Object> get props => [host, port, username, password, useSsl];
}
