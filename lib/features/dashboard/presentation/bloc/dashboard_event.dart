import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class RefreshSystemResources extends DashboardEvent {
  const RefreshSystemResources();
}

class LoadInterfaces extends DashboardEvent {
  const LoadInterfaces();
}

class ToggleInterface extends DashboardEvent {
  final String id;
  final bool enable;

  const ToggleInterface({required this.id, required this.enable});

  @override
  List<Object> get props => [id, enable];
}

class LoadIpAddresses extends DashboardEvent {
  const LoadIpAddresses();
}

class LoadFirewallRules extends DashboardEvent {
  const LoadFirewallRules();
}

class ToggleFirewallRule extends DashboardEvent {
  final String id;
  final bool enable;

  const ToggleFirewallRule({required this.id, required this.enable});

  @override
  List<Object> get props => [id, enable];
}
