import '../../domain/entities/cloud_status.dart';

class CloudStatusModel extends CloudStatus {
  const CloudStatusModel({
    required super.ddnsEnabled,
    super.ddnsUpdateInterval,
    required super.updateTime,
    super.publicAddress,
    super.dnsName,
    super.status,
    super.backToHomeVpn,
    super.warning,
    super.isSupported,
  });

  factory CloudStatusModel.fromMap(Map<String, String> map) {
    // Check for warning comment (x86/CHR detection)
    final comment = map['comment'] ?? '';
    final isSupported = !comment.contains('not supported on x86');

    return CloudStatusModel(
      ddnsEnabled: map['ddns-enabled'] == 'true' || map['ddns-enabled'] == 'yes',
      ddnsUpdateInterval: map['ddns-update-interval'],
      updateTime: map['update-time'] == 'true' || map['update-time'] == 'yes',
      publicAddress: map['public-address'],
      dnsName: map['dns-name'],
      status: map['status'],
      backToHomeVpn: map['back-to-home-vpn'],
      warning: comment.isNotEmpty ? comment : null,
      isSupported: isSupported,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ddns-enabled': ddnsEnabled ? 'yes' : 'no',
      'ddns-update-interval': ddnsUpdateInterval,
      'update-time': updateTime ? 'yes' : 'no',
      'public-address': publicAddress,
      'dns-name': dnsName,
      'status': status,
      'back-to-home-vpn': backToHomeVpn,
    };
  }
}
