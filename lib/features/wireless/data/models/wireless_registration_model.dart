import '../../domain/entities/wireless_registration.dart';

class WirelessRegistrationModel extends WirelessRegistration {
  const WirelessRegistrationModel({
    required super.id,
    required super.interface,
    required super.macAddress,
    required super.ipAddress,
    required super.signalStrength,
    required super.txRate,
    required super.rxRate,
    required super.uptime,
    required super.hostname,
    required super.comment,
  });

  factory WirelessRegistrationModel.fromMap(Map<String, dynamic> map) {
    return WirelessRegistrationModel(
      id: map['.id'] ?? '',
      interface: map['interface'] ?? '',
      macAddress: map['mac-address'] ?? '',
      ipAddress: map['last-ip'] ?? '',
      signalStrength: int.tryParse(map['signal-strength'] ?? '0') ?? 0,
      txRate: int.tryParse(map['tx-rate'] ?? '0') ?? 0,
      rxRate: int.tryParse(map['rx-rate'] ?? '0') ?? 0,
      uptime: map['uptime'] ?? '00:00:00',
      hostname: map['hostname'] ?? '',
      comment: map['comment'] ?? '',
    );
  }

  factory WirelessRegistrationModel.fromEntity(WirelessRegistration entity) {
    return WirelessRegistrationModel(
      id: entity.id,
      interface: entity.interface,
      macAddress: entity.macAddress,
      ipAddress: entity.ipAddress,
      signalStrength: entity.signalStrength,
      txRate: entity.txRate,
      rxRate: entity.rxRate,
      uptime: entity.uptime,
      hostname: entity.hostname,
      comment: entity.comment,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'interface': interface,
      'mac-address': macAddress,
      'last-ip': ipAddress,
      'signal-strength': signalStrength.toString(),
      'tx-rate': txRate.toString(),
      'rx-rate': rxRate.toString(),
      'uptime': uptime,
      'hostname': hostname,
      'comment': comment,
    };
  }
}