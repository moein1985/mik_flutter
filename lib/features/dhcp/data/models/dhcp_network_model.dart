import '../../domain/entities/dhcp_network.dart';

class DhcpNetworkModel extends DhcpNetwork {
  const DhcpNetworkModel({
    required super.id,
    required super.address,
    super.gateway,
    super.netmask,
    super.dnsServer,
    super.domain,
    super.winsServer,
    super.ntpServer,
    super.comment,
  });

  factory DhcpNetworkModel.fromMap(Map<String, String> map) {
    return DhcpNetworkModel(
      id: map['.id'] ?? '',
      address: map['address'] ?? '',
      gateway: map['gateway'],
      netmask: map['netmask'],
      dnsServer: map['dns-server'],
      domain: map['domain'],
      winsServer: map['wins-server'],
      ntpServer: map['ntp-server'],
      comment: map['comment'],
    );
  }
}
