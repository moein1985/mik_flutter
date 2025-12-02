import '../../domain/entities/hotspot_host.dart';

class HotspotHostModel extends HotspotHost {
  const HotspotHostModel({
    required super.id,
    required super.macAddress,
    super.address,
    super.toAddress,
    super.server,
    required super.authorized,
    required super.bypassed,
    super.comment,
    super.uptime,
    super.idleTime,
    super.keepaliveTimeout,
    super.loginBy,
    super.bytesIn,
    super.bytesOut,
    super.packetsIn,
    super.packetsOut,
    super.macBrand,
    super.hostName,
    super.radiusResponse,
  });

  factory HotspotHostModel.fromMap(Map<String, dynamic> map) {
    return HotspotHostModel(
      id: map['.id'] ?? '',
      macAddress: map['mac-address'] ?? '',
      address: map['address'],
      toAddress: map['to-address'],
      server: map['server'],
      authorized: map['authorized'] == 'true',
      bypassed: map['bypassed'] == 'true',
      comment: map['comment'],
      uptime: map['uptime'],
      idleTime: map['idle-time'],
      keepaliveTimeout: map['keepalive-timeout'],
      loginBy: map['login-by'],
      bytesIn: map['bytes-in'],
      bytesOut: map['bytes-out'],
      packetsIn: map['packets-in'],
      packetsOut: map['packets-out'],
      macBrand: map['mac-brand'],
      hostName: map['host-name'],
      radiusResponse: map['radius-response'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'mac-address': macAddress,
      if (address != null) 'address': address,
      if (toAddress != null) 'to-address': toAddress,
      if (server != null) 'server': server,
      'authorized': authorized ? 'true' : 'false',
      'bypassed': bypassed ? 'true' : 'false',
      if (comment != null) 'comment': comment,
      if (uptime != null) 'uptime': uptime,
      if (idleTime != null) 'idle-time': idleTime,
      if (keepaliveTimeout != null) 'keepalive-timeout': keepaliveTimeout,
      if (loginBy != null) 'login-by': loginBy,
      if (bytesIn != null) 'bytes-in': bytesIn,
      if (bytesOut != null) 'bytes-out': bytesOut,
      if (packetsIn != null) 'packets-in': packetsIn,
      if (packetsOut != null) 'packets-out': packetsOut,
      if (macBrand != null) 'mac-brand': macBrand,
      if (hostName != null) 'host-name': hostName,
      if (radiusResponse != null) 'radius-response': radiusResponse,
    };
  }
}
