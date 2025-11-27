import '../../domain/entities/hotspot_profile.dart';

class HotspotProfileModel extends HotspotProfile {
  const HotspotProfileModel({
    required super.id,
    required super.name,
    super.sessionTimeout,
    super.idleTimeout,
    super.sharedUsers,
    super.rateLimit,
    super.keepaliveTimeout,
    super.statusAutorefresh,
    super.onLogin,
    super.onLogout,
  });

  factory HotspotProfileModel.fromMap(Map<String, dynamic> map) {
    return HotspotProfileModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      sessionTimeout: map['session-timeout'],
      idleTimeout: map['idle-timeout'],
      sharedUsers: map['shared-users'],
      rateLimit: map['rate-limit'],
      keepaliveTimeout: map['keepalive-timeout'],
      statusAutorefresh: map['status-autorefresh'],
      onLogin: map['on-login'],
      onLogout: map['on-logout'],
    );
  }
}
