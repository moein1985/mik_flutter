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
    required super.dynamic,
    required super.disabled,
  });

  factory DhcpLeaseModel.fromMap(Map<String, String> map) {
    return DhcpLeaseModel(
      id: map['.id'] ?? '',
      address: map['address'] ?? '',
      macAddress: map['mac-address'] ?? '',
      hostName: map['host-name'],
      comment: map['comment'],
      status: map['status'] ?? '',
      expiresAfter: map['expires-after'],
      dynamic: map['dynamic'] == 'true',
      disabled: map['disabled'] == 'true',
    );
  }
}
