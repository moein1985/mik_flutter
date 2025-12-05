import 'package:equatable/equatable.dart';

class DhcpNetwork extends Equatable {
  final String id;
  final String address;
  final String? gateway;
  final String? netmask;
  final String? dnsServer;
  final String? domain;
  final String? winsServer;
  final String? ntpServer;
  final String? comment;

  const DhcpNetwork({
    required this.id,
    required this.address,
    this.gateway,
    this.netmask,
    this.dnsServer,
    this.domain,
    this.winsServer,
    this.ntpServer,
    this.comment,
  });

  @override
  List<Object?> get props => [
        id,
        address,
        gateway,
        netmask,
        dnsServer,
        domain,
        winsServer,
        ntpServer,
        comment,
      ];
}
