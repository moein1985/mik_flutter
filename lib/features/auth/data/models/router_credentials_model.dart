import '../../domain/entities/router_credentials.dart';

class RouterCredentialsModel extends RouterCredentials {
  const RouterCredentialsModel({
    required super.host,
    required super.port,
    required super.username,
    required super.password,
    super.useSsl = false,
  });

  factory RouterCredentialsModel.fromJson(Map<String, dynamic> json) {
    return RouterCredentialsModel(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
      useSsl: json['useSsl'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'useSsl': useSsl,
    };
  }

  factory RouterCredentialsModel.fromEntity(RouterCredentials credentials) {
    return RouterCredentialsModel(
      host: credentials.host,
      port: credentials.port,
      username: credentials.username,
      password: credentials.password,
      useSsl: credentials.useSsl,
    );
  }
}
