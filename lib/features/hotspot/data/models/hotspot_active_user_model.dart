import '../../domain/entities/hotspot_active_user.dart';

class HotspotActiveUserModel extends HotspotActiveUser {
  const HotspotActiveUserModel({
    required super.id,
    required super.user,
    required super.server,
    required super.address,
    required super.macAddress,
    required super.loginBy,
    required super.uptime,
    required super.sessionTimeLeft,
    required super.idleTime,
    required super.bytesIn,
    required super.bytesOut,
    required super.packetsIn,
    required super.packetsOut,
  });

  factory HotspotActiveUserModel.fromMap(Map<String, dynamic> map) {
    return HotspotActiveUserModel(
      id: map['.id'] ?? '',
      user: map['user'] ?? '',
      server: map['server'] ?? '',
      address: map['address'] ?? '',
      macAddress: map['mac-address'] ?? '',
      loginBy: map['login-by'] ?? '',
      uptime: map['uptime'] ?? '0',
      sessionTimeLeft: map['session-time-left'] ?? '',
      idleTime: map['idle-time'] ?? '0',
      bytesIn: map['bytes-in'] ?? '0',
      bytesOut: map['bytes-out'] ?? '0',
      packetsIn: map['packets-in'] ?? '0',
      packetsOut: map['packets-out'] ?? '0',
    );
  }
}
