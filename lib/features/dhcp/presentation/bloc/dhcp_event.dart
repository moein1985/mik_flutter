import 'package:equatable/equatable.dart';

abstract class DhcpEvent extends Equatable {
  const DhcpEvent();

  @override
  List<Object?> get props => [];
}

// ==================== Server Events ====================

class LoadDhcpServers extends DhcpEvent {
  const LoadDhcpServers();
}

class AddDhcpServer extends DhcpEvent {
  final String name;
  final String interface;
  final String? addressPool;
  final String? leaseTime;
  final bool? authoritative;
  // Network parameters for automatic network creation
  final String? networkAddress;
  final String? gateway;
  final String? dnsServer;

  const AddDhcpServer({
    required this.name,
    required this.interface,
    this.addressPool,
    this.leaseTime,
    this.authoritative,
    this.networkAddress,
    this.gateway,
    this.dnsServer,
  });

  @override
  List<Object?> get props => [name, interface, addressPool, leaseTime, authoritative, networkAddress, gateway, dnsServer];
}

class EditDhcpServer extends DhcpEvent {
  final String id;
  final String? name;
  final String? interface;
  final String? addressPool;
  final String? leaseTime;
  final bool? authoritative;

  const EditDhcpServer({
    required this.id,
    this.name,
    this.interface,
    this.addressPool,
    this.leaseTime,
    this.authoritative,
  });

  @override
  List<Object?> get props => [id, name, interface, addressPool, leaseTime, authoritative];
}

class RemoveDhcpServer extends DhcpEvent {
  final String id;

  const RemoveDhcpServer(this.id);

  @override
  List<Object> get props => [id];
}

class EnableDhcpServer extends DhcpEvent {
  final String id;

  const EnableDhcpServer(this.id);

  @override
  List<Object> get props => [id];
}

class DisableDhcpServer extends DhcpEvent {
  final String id;

  const DisableDhcpServer(this.id);

  @override
  List<Object> get props => [id];
}

// ==================== Network Events ====================

class LoadDhcpNetworks extends DhcpEvent {
  const LoadDhcpNetworks();
}

class AddDhcpNetwork extends DhcpEvent {
  final String address;
  final String? gateway;
  final String? netmask;
  final String? dnsServer;
  final String? domain;
  final String? comment;

  const AddDhcpNetwork({
    required this.address,
    this.gateway,
    this.netmask,
    this.dnsServer,
    this.domain,
    this.comment,
  });

  @override
  List<Object?> get props => [address, gateway, netmask, dnsServer, domain, comment];
}

class EditDhcpNetwork extends DhcpEvent {
  final String id;
  final String? address;
  final String? gateway;
  final String? netmask;
  final String? dnsServer;
  final String? domain;
  final String? comment;

  const EditDhcpNetwork({
    required this.id,
    this.address,
    this.gateway,
    this.netmask,
    this.dnsServer,
    this.domain,
    this.comment,
  });

  @override
  List<Object?> get props => [id, address, gateway, netmask, dnsServer, domain, comment];
}

class RemoveDhcpNetwork extends DhcpEvent {
  final String id;

  const RemoveDhcpNetwork(this.id);

  @override
  List<Object> get props => [id];
}

// ==================== Lease Events ====================

class LoadDhcpLeases extends DhcpEvent {
  const LoadDhcpLeases();
}

class AddDhcpLease extends DhcpEvent {
  final String address;
  final String macAddress;
  final String? server;
  final String? comment;

  const AddDhcpLease({
    required this.address,
    required this.macAddress,
    this.server,
    this.comment,
  });

  @override
  List<Object?> get props => [address, macAddress, server, comment];
}

class RemoveDhcpLease extends DhcpEvent {
  final String id;

  const RemoveDhcpLease(this.id);

  @override
  List<Object> get props => [id];
}

class MakeDhcpLeaseStatic extends DhcpEvent {
  final String id;

  const MakeDhcpLeaseStatic(this.id);

  @override
  List<Object> get props => [id];
}

class EnableDhcpLease extends DhcpEvent {
  final String id;

  const EnableDhcpLease(this.id);

  @override
  List<Object> get props => [id];
}

class DisableDhcpLease extends DhcpEvent {
  final String id;

  const DisableDhcpLease(this.id);

  @override
  List<Object> get props => [id];
}

// ==================== Helper Events ====================

class LoadDhcpSetupData extends DhcpEvent {
  const LoadDhcpSetupData();
}

class AddIpPool extends DhcpEvent {
  final String name;
  final String ranges;

  const AddIpPool({
    required this.name,
    required this.ranges,
  });

  @override
  List<Object> get props => [name, ranges];
}
