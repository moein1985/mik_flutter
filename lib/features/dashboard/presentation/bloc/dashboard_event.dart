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

class AddIpAddress extends DashboardEvent {
  final String address;
  final String interfaceName;
  final String? comment;

  const AddIpAddress({
    required this.address,
    required this.interfaceName,
    this.comment,
  });

  @override
  List<Object?> get props => [address, interfaceName, comment];
}

class UpdateIpAddress extends DashboardEvent {
  final String id;
  final String? address;
  final String? interfaceName;
  final String? comment;

  const UpdateIpAddress({
    required this.id,
    this.address,
    this.interfaceName,
    this.comment,
  });

  @override
  List<Object?> get props => [id, address, interfaceName, comment];
}

class RemoveIpAddress extends DashboardEvent {
  final String id;

  const RemoveIpAddress(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleIpAddress extends DashboardEvent {
  final String id;
  final bool enable;

  const ToggleIpAddress({required this.id, required this.enable});

  @override
  List<Object> get props => [id, enable];
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

class ClearError extends DashboardEvent {
  const ClearError();
}
