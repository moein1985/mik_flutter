import '../../domain/entities/router_credentials.dart';

class RouterCredentialsModel extends RouterCredentials {
  const RouterCredentialsModel({
    required super.host,
    required super.port,
    required super.username,
    required super.password,
  });

  factory RouterCredentialsModel.fromJson(Map<String, dynamic> json) {
    return RouterCredentialsModel(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  factory RouterCredentialsModel.fromEntity(RouterCredentials credentials) {
    return RouterCredentialsModel(
      host: credentials.host,
      port: credentials.port,
      username: credentials.username,
      password: credentials.password,
    );
  }
}
