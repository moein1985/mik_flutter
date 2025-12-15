import 'package:equatable/equatable.dart';
import '../../domain/entities/system_resource.dart';
import '../../domain/entities/router_interface.dart';
import '../../domain/entities/ip_address.dart';
import '../../domain/entities/firewall_rule.dart';

/// Sealed class for exhaustive matching in UI
sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state when fetching initial dashboard data
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Success state with all dashboard data (non-nullable!)
final class DashboardLoaded extends DashboardState {
  final SystemResource? systemResource;
  final List<RouterInterface>? interfaces;
  final List<IpAddress>? ipAddresses;
  final List<FirewallRule>? firewallRules;
  final String? errorMessage; // For showing errors without losing data

  const DashboardLoaded({
    this.systemResource,
    this.interfaces,
    this.ipAddresses,
    this.firewallRules,
    this.errorMessage,
  });

  DashboardLoaded copyWith({
    SystemResource? systemResource,
    List<RouterInterface>? interfaces,
    List<IpAddress>? ipAddresses,
    List<FirewallRule>? firewallRules,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardLoaded(
      systemResource: systemResource ?? this.systemResource,
      interfaces: interfaces ?? this.interfaces,
      ipAddresses: ipAddresses ?? this.ipAddresses,
      firewallRules: firewallRules ?? this.firewallRules,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [systemResource, interfaces, ipAddresses, firewallRules, errorMessage];
}

/// Error state when initial loading fails
final class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

/// Loading state for operations (toggle, enable, disable, etc.)
final class DashboardOperationLoading extends DashboardState {
  const DashboardOperationLoading();
}

/// Success state for operations
final class DashboardOperationSuccess extends DashboardState {
  final String message;

  const DashboardOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
