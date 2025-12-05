import '../../domain/entities/dhcp_lease.dart';

class DhcpLeaseModel extends DhcpLease {
  const DhcpLeaseModel({
    required super.id,
    required super.address,
    required super.macAddress,
    super.hostName,
    super.comment,
    required super.status,
    super.expiresAfter,
    super.server,
    super.lastSeen,
    required super.dynamic,
    required super.disabled,
    required super.blocked,
  });

  factory DhcpLeaseModel.fromMap(Map<String, String> map) {
    return DhcpLeaseModel(
      id: map['.id'] ?? '',
      address: map['address'] ?? '',
      macAddress: map['mac-address'] ?? '',
      hostName: map['host-name'],
      comment: map['comment'],
      status: map['status'] ?? 'unknown',
      expiresAfter: map['expires-after'],
      server: map['server'],
      lastSeen: map['last-seen'],
      dynamic: map['dynamic'] == 'true',
      disabled: map['disabled'] == 'true',
      blocked: map['blocked'] == 'true',
    );
  }
}
