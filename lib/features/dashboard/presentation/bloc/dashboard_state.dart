import 'package:equatable/equatable.dart';
import '../../domain/entities/system_resource.dart';
import '../../domain/entities/router_interface.dart';
import '../../domain/entities/ip_address.dart';
import '../../domain/entities/firewall_rule.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final SystemResource? systemResource;
  final List<RouterInterface>? interfaces;
  final List<IpAddress>? ipAddresses;
  final List<FirewallRule>? firewallRules;

  const DashboardLoaded({
    this.systemResource,
    this.interfaces,
    this.ipAddresses,
    this.firewallRules,
  });

  DashboardLoaded copyWith({
    SystemResource? systemResource,
    List<RouterInterface>? interfaces,
    List<IpAddress>? ipAddresses,
    List<FirewallRule>? firewallRules,
  }) {
    return DashboardLoaded(
      systemResource: systemResource ?? this.systemResource,
      interfaces: interfaces ?? this.interfaces,
      ipAddresses: ipAddresses ?? this.ipAddresses,
      firewallRules: firewallRules ?? this.firewallRules,
    );
  }

  @override
  List<Object?> get props => [systemResource, interfaces, ipAddresses, firewallRules];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

class DashboardOperationLoading extends DashboardState {
  const DashboardOperationLoading();
}

class DashboardOperationSuccess extends DashboardState {
  final String message;

  const DashboardOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
