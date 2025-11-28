import '../../domain/entities/hotspot_user.dart';

class HotspotUserModel extends HotspotUser {
  const HotspotUserModel({
    required super.id,
    required super.name,
    super.password,
    super.profile,
    super.server,
    super.uptime,
    super.bytesIn,
    super.bytesOut,
    super.packetsIn,
    super.packetsOut,
    super.comment,
    required super.disabled,
  });

  factory HotspotUserModel.fromMap(Map<String, dynamic> map) {
    return HotspotUserModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      password: map['password'],
      profile: map['profile'],
      server: map['server'],
      uptime: map['uptime'],
      bytesIn: map['bytes-in'],
      bytesOut: map['bytes-out'],
      packetsIn: map['packets-in'],
      packetsOut: map['packets-out'],
      comment: map['comment'],
      disabled: map['disabled'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'name': name,
      if (password != null) 'password': password,
      if (profile != null) 'profile': profile,
      if (server != null) 'server': server,
      if (uptime != null) 'uptime': uptime,
      if (bytesIn != null) 'bytes-in': bytesIn,
      if (bytesOut != null) 'bytes-out': bytesOut,
      if (packetsIn != null) 'packets-in': packetsIn,
      if (packetsOut != null) 'packets-out': packetsOut,
      if (comment != null) 'comment': comment,
      'disabled': disabled ? 'true' : 'false',
    };
  }
}
