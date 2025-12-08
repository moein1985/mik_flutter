import 'package:equatable/equatable.dart';

class WirelessRegistration extends Equatable {
  final String id;
  final String interface;
  final String macAddress;
  final String ipAddress;
  final int signalStrength; // in dBm
  final int txRate;
  final int rxRate;
  final String uptime;
  final String hostname;
  final String comment;

  const WirelessRegistration({
    required this.id,
    required this.interface,
    required this.macAddress,
    required this.ipAddress,
    required this.signalStrength,
    required this.txRate,
    required this.rxRate,
    required this.uptime,
    required this.hostname,
    required this.comment,
  });

  factory WirelessRegistration.fromMap(Map<String, dynamic> map) {
    return WirelessRegistration(
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

  // Helper method to get signal strength category
  String get signalStrengthCategory {
    if (signalStrength >= -30) return 'excellent';
    if (signalStrength >= -50) return 'good';
    if (signalStrength >= -70) return 'fair';
    return 'poor';
  }

  // Helper method to get signal strength color
  String get signalStrengthColor {
    switch (signalStrengthCategory) {
      case 'excellent':
        return 'green';
      case 'good':
        return 'blue';
      case 'fair':
        return 'orange';
      case 'poor':
        return 'red';
      default:
        return 'grey';
    }
  }

  WirelessRegistration copyWith({
    String? id,
    String? interface,
    String? macAddress,
    String? ipAddress,
    int? signalStrength,
    int? txRate,
    int? rxRate,
    String? uptime,
    String? hostname,
    String? comment,
  }) {
    return WirelessRegistration(
      id: id ?? this.id,
      interface: interface ?? this.interface,
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      signalStrength: signalStrength ?? this.signalStrength,
      txRate: txRate ?? this.txRate,
      rxRate: rxRate ?? this.rxRate,
      uptime: uptime ?? this.uptime,
      hostname: hostname ?? this.hostname,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [
        id,
        interface,
        macAddress,
        ipAddress,
        signalStrength,
        txRate,
        rxRate,
        uptime,
        hostname,
        comment,
      ];
}