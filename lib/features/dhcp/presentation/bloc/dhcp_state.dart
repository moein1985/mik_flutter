import 'package:equatable/equatable.dart';
import '../../domain/entities/dhcp_server.dart';
import '../../domain/entities/dhcp_network.dart';
import '../../domain/entities/dhcp_lease.dart';

abstract class DhcpState extends Equatable {
  const DhcpState();

  @override
  List<Object?> get props => [];
}

class DhcpInitial extends DhcpState {
  const DhcpInitial();
}

class DhcpLoading extends DhcpState {
  const DhcpLoading();
}

class DhcpLoaded extends DhcpState {
  final List<DhcpServer>? servers;
  final List<DhcpNetwork>? networks;
  final List<DhcpLease>? leases;

  const DhcpLoaded({
    this.servers,
    this.networks,
    this.leases,
  });

  DhcpLoaded copyWith({
    List<DhcpServer>? servers,
    List<DhcpNetwork>? networks,
    List<DhcpLease>? leases,
  }) {
    return DhcpLoaded(
      servers: servers ?? this.servers,
      networks: networks ?? this.networks,
      leases: leases ?? this.leases,
    );
  }

  @override
  List<Object?> get props => [servers, networks, leases];
}

class DhcpError extends DhcpState {
  final String message;

  const DhcpError(this.message);

  @override
  List<Object> get props => [message];
}

class DhcpOperationSuccess extends DhcpState {
  final String message;
  final DhcpLoaded? previousData;

  const DhcpOperationSuccess(this.message, {this.previousData});

  @override
  List<Object?> get props => [message, previousData];
}

class DhcpSetupDataLoaded extends DhcpState {
  final List<Map<String, String>> interfaces;
  final List<Map<String, String>> ipPools;

  const DhcpSetupDataLoaded({
    required this.interfaces,
    required this.ipPools,
  });

  @override
  List<Object> get props => [interfaces, ipPools];
}
