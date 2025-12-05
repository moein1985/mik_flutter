import '../../domain/entities/ip_service.dart';

/// Model class for IpService with JSON serialization
class IpServiceModel extends IpService {
  const IpServiceModel({
    required super.id,
    required super.name,
    required super.port,
    super.address,
    super.certificate,
    super.disabled,
    super.invalid,
    super.vrf,
    super.maxSessions,
    super.tlsVersion,
  });

  factory IpServiceModel.fromRouterOS(Map<String, String> data) {
    return IpServiceModel(
      id: data['.id'] ?? '',
      name: data['name'] ?? '',
      port: int.tryParse(data['port'] ?? '0') ?? 0,
      address: data['address'] ?? '',
      certificate: data['certificate'],
      disabled: data['disabled'] == 'true',
      invalid: data['invalid'] == 'true',
      vrf: data['vrf'],
      maxSessions: int.tryParse(data['max-sessions'] ?? ''),
      tlsVersion: data['tls-version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '.id': id,
      'name': name,
      'port': port.toString(),
      'address': address,
      'certificate': certificate,
      'disabled': disabled.toString(),
      'invalid': invalid.toString(),
      'vrf': vrf,
      'max-sessions': maxSessions?.toString(),
      'tls-version': tlsVersion,
    };
  }

  IpService toEntity() => IpService(
        id: id,
        name: name,
        port: port,
        address: address,
        certificate: certificate,
        disabled: disabled,
        invalid: invalid,
        vrf: vrf,
        maxSessions: maxSessions,
        tlsVersion: tlsVersion,
      );
}
