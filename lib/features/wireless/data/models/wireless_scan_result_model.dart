import '../../domain/entities/wireless_scan_result.dart';

class WirelessScanResultModel extends WirelessScanResult {
  const WirelessScanResultModel({
    required super.ssid,
    required super.macAddress,
    required super.channel,
    required super.signalStrength,
    required super.band,
    required super.security,
    super.routerosVersion,
  });

  factory WirelessScanResultModel.fromMap(Map<String, dynamic> map) {
    return WirelessScanResultModel(
      ssid: map['ssid'] ?? '',
      macAddress: map['address'] ?? '',
      channel: map['channel'] ?? '',
      signalStrength: int.tryParse(map['signal-strength']?.toString() ?? '0') ?? 0,
      band: map['band'] ?? '',
      security: map['security'] ?? 'open',
      routerosVersion: map['routeros-version'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ssid': ssid,
      'address': macAddress,
      'channel': channel,
      'signal-strength': signalStrength.toString(),
      'band': band,
      'security': security,
      if (routerosVersion != null) 'routeros-version': routerosVersion,
    };
  }

  factory WirelessScanResultModel.fromEntity(WirelessScanResult entity) {
    return WirelessScanResultModel(
      ssid: entity.ssid,
      macAddress: entity.macAddress,
      channel: entity.channel,
      signalStrength: entity.signalStrength,
      band: entity.band,
      security: entity.security,
      routerosVersion: entity.routerosVersion,
    );
  }
}
