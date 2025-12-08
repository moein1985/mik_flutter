import '../../domain/entities/wireless_interface.dart';

class WirelessInterfaceModel extends WirelessInterface {
  const WirelessInterfaceModel({
    required super.id,
    required super.name,
    required super.ssid,
    required super.frequency,
    required super.band,
    required super.disabled,
    required super.status,
    required super.clients,
    required super.macAddress,
    required super.mode,
    required super.security,
    required super.txPower,
    required super.channelWidth,
  });

  factory WirelessInterfaceModel.fromMap(Map<String, dynamic> map) {
    return WirelessInterfaceModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      ssid: map['ssid'] ?? '',
      frequency: map['frequency'] ?? '',
      band: map['band'] ?? '',
      disabled: map['disabled'] == 'true',
      status: map['running'] == 'true' ? 'running' : 'stopped',
      clients: int.tryParse(map['registered-clients'] ?? '0') ?? 0,
      macAddress: map['mac-address'] ?? '',
      mode: map['mode'] ?? '',
      security: map['security-profile'] ?? '',
      txPower: int.tryParse(map['tx-power'] ?? '0') ?? 0,
      channelWidth: int.tryParse(map['channel-width'] ?? '20') ?? 20,
    );
  }

  factory WirelessInterfaceModel.fromEntity(WirelessInterface entity) {
    return WirelessInterfaceModel(
      id: entity.id,
      name: entity.name,
      ssid: entity.ssid,
      frequency: entity.frequency,
      band: entity.band,
      disabled: entity.disabled,
      status: entity.status,
      clients: entity.clients,
      macAddress: entity.macAddress,
      mode: entity.mode,
      security: entity.security,
      txPower: entity.txPower,
      channelWidth: entity.channelWidth,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'name': name,
      'ssid': ssid,
      'frequency': frequency,
      'band': band,
      'disabled': disabled.toString(),
      'running': status == 'running' ? 'true' : 'false',
      'registered-clients': clients.toString(),
      'mac-address': macAddress,
      'mode': mode,
      'security-profile': security,
      'tx-power': txPower.toString(),
      'channel-width': channelWidth.toString(),
    };
  }
}