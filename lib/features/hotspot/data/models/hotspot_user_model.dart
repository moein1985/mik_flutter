import '../../domain/entities/hotspot_user.dart';

class HotspotUserModel extends HotspotUser {
  const HotspotUserModel({
    required super.id,
    required super.name,
    super.password,
    super.profile,
    super.server,
    super.comment,
    required super.disabled,
    // Limits
    super.limitUptime,
    super.limitBytesIn,
    super.limitBytesOut,
    super.limitBytesTotal,
    // Statistics
    super.uptime,
    super.bytesIn,
    super.bytesOut,
    super.packetsIn,
    super.packetsOut,
  });

  factory HotspotUserModel.fromMap(Map<String, dynamic> map) {
    return HotspotUserModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      password: map['password'],
      profile: map['profile'],
      server: map['server'],
      comment: map['comment'],
      disabled: map['disabled'] == 'true',
      // Limits
      limitUptime: map['limit-uptime'],
      limitBytesIn: map['limit-bytes-in'],
      limitBytesOut: map['limit-bytes-out'],
      limitBytesTotal: map['limit-bytes-total'],
      // Statistics
      uptime: map['uptime'],
      bytesIn: map['bytes-in'],
      bytesOut: map['bytes-out'],
      packetsIn: map['packets-in'],
      packetsOut: map['packets-out'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'name': name,
      if (password != null) 'password': password,
      if (profile != null) 'profile': profile,
      if (server != null) 'server': server,
      if (comment != null) 'comment': comment,
      'disabled': disabled ? 'true' : 'false',
      // Limits
      if (limitUptime != null) 'limit-uptime': limitUptime,
      if (limitBytesIn != null) 'limit-bytes-in': limitBytesIn,
      if (limitBytesOut != null) 'limit-bytes-out': limitBytesOut,
      if (limitBytesTotal != null) 'limit-bytes-total': limitBytesTotal,
      // Statistics (read-only, but included for completeness)
      if (uptime != null) 'uptime': uptime,
      if (bytesIn != null) 'bytes-in': bytesIn,
      if (bytesOut != null) 'bytes-out': bytesOut,
      if (packetsIn != null) 'packets-in': packetsIn,
      if (packetsOut != null) 'packets-out': packetsOut,
    };
  }
}
