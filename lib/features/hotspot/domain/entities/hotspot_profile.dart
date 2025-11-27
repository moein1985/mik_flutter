import 'package:equatable/equatable.dart';

class HotspotProfile extends Equatable {
  final String id;
  final String name;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? sharedUsers;
  final String? rateLimit;
  final String? keepaliveTimeout;
  final String? statusAutorefresh;
  final String? onLogin;
  final String? onLogout;

  const HotspotProfile({
    required this.id,
    required this.name,
    this.sessionTimeout,
    this.idleTimeout,
    this.sharedUsers,
    this.rateLimit,
    this.keepaliveTimeout,
    this.statusAutorefresh,
    this.onLogin,
    this.onLogout,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        sessionTimeout,
        idleTimeout,
        sharedUsers,
        rateLimit,
        keepaliveTimeout,
        statusAutorefresh,
        onLogin,
        onLogout,
      ];
}
