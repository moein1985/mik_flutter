import '../../domain/entities/router_session.dart';

class RouterSessionModel extends RouterSession {
  const RouterSessionModel({
    required super.host,
    required super.port,
    required super.username,
    required super.connectedAt,
    super.useSsl = false,
  });

  factory RouterSessionModel.fromJson(Map<String, dynamic> json) {
    return RouterSessionModel(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      useSsl: json['useSsl'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'connectedAt': connectedAt.toIso8601String(),
      'useSsl': useSsl,
    };
  }
}
