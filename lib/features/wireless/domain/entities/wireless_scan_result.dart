import 'package:equatable/equatable.dart';

class WirelessScanResult extends Equatable {
  final String ssid;
  final String macAddress;
  final String channel;
  final int signalStrength; // in dBm
  final String band;
  final String security;
  final String? routerosVersion;

  const WirelessScanResult({
    required this.ssid,
    required this.macAddress,
    required this.channel,
    required this.signalStrength,
    required this.band,
    required this.security,
    this.routerosVersion,
  });

  @override
  List<Object?> get props => [
        ssid,
        macAddress,
        channel,
        signalStrength,
        band,
        security,
        routerosVersion,
      ];

  @override
  String toString() {
    return 'WirelessScanResult(ssid: $ssid, macAddress: $macAddress, '
        'channel: $channel, signalStrength: $signalStrength, '
        'band: $band, security: $security)';
  }

  WirelessScanResult copyWith({
    String? ssid,
    String? macAddress,
    String? channel,
    int? signalStrength,
    String? band,
    String? security,
    String? routerosVersion,
  }) {
    return WirelessScanResult(
      ssid: ssid ?? this.ssid,
      macAddress: macAddress ?? this.macAddress,
      channel: channel ?? this.channel,
      signalStrength: signalStrength ?? this.signalStrength,
      band: band ?? this.band,
      security: security ?? this.security,
      routerosVersion: routerosVersion ?? this.routerosVersion,
    );
  }
}
