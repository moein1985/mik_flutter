import '../../domain/entities/dhcp_server.dart';

class DhcpServerModel extends DhcpServer {
  const DhcpServerModel({
    required super.id,
    required super.name,
    required super.interface,
    super.addressPool,
    required super.leaseTime,
    required super.disabled,
    required super.invalid,
    required super.authoritative,
    super.useRadius,
    super.relayAddress,
  });

  factory DhcpServerModel.fromMap(Map<String, String> map) {
    return DhcpServerModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      interface: map['interface'] ?? '',
      addressPool: map['address-pool'],
      leaseTime: map['lease-time'] ?? '10m',
      disabled: map['disabled'] == 'true',
      invalid: map['invalid'] == 'true',
      authoritative: map['authoritative'] == 'yes' || map['authoritative'] == 'true',
      useRadius: map['use-radius'],
      relayAddress: map['relay'],
    );
  }
}
