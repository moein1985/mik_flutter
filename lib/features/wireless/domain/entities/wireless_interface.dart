import 'package:equatable/equatable.dart';

class WirelessInterface extends Equatable {
  final String id;
  final String name;
  final String ssid;
  final String frequency;
  final String band;
  final bool disabled;
  final String status;
  final int clients;
  final String macAddress;
  final String mode;
  final String security;
  final int txPower;
  final int channelWidth;

  const WirelessInterface({
    required this.id,
    required this.name,
    required this.ssid,
    required this.frequency,
    required this.band,
    required this.disabled,
    required this.status,
    required this.clients,
    required this.macAddress,
    required this.mode,
    required this.security,
    required this.txPower,
    required this.channelWidth,
  });

  factory WirelessInterface.fromMap(Map<String, dynamic> map) {
    return WirelessInterface(
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

  WirelessInterface copyWith({
    String? id,
    String? name,
    String? ssid,
    String? frequency,
    String? band,
    bool? disabled,
    String? status,
    int? clients,
    String? macAddress,
    String? mode,
    String? security,
    int? txPower,
    int? channelWidth,
  }) {
    return WirelessInterface(
      id: id ?? this.id,
      name: name ?? this.name,
      ssid: ssid ?? this.ssid,
      frequency: frequency ?? this.frequency,
      band: band ?? this.band,
      disabled: disabled ?? this.disabled,
      status: status ?? this.status,
      clients: clients ?? this.clients,
      macAddress: macAddress ?? this.macAddress,
      mode: mode ?? this.mode,
      security: security ?? this.security,
      txPower: txPower ?? this.txPower,
      channelWidth: channelWidth ?? this.channelWidth,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ssid,
        frequency,
        band,
        disabled,
        status,
        clients,
        macAddress,
        mode,
        security,
        txPower,
        channelWidth,
      ];
}