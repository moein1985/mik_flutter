import 'package:equatable/equatable.dart';
import '../../domain/entities/firewall_rule.dart';

abstract class FirewallEvent extends Equatable {
  const FirewallEvent();

  @override
  List<Object?> get props => [];
}

/// Load firewall rules for a specific type
class LoadFirewallRules extends FirewallEvent {
  final FirewallRuleType type;

  const LoadFirewallRules(this.type);

  @override
  List<Object?> get props => [type];
}

/// Toggle a firewall rule (enable/disable)
class ToggleFirewallRule extends FirewallEvent {
  final FirewallRuleType type;
  final String id;
  final bool enable;

  const ToggleFirewallRule({
    required this.type,
    required this.id,
    required this.enable,
  });

  @override
  List<Object?> get props => [type, id, enable];
}

/// Load address list names for filtering
class LoadAddressListNames extends FirewallEvent {
  const LoadAddressListNames();
}

/// Load address list entries by list name
class LoadAddressListByName extends FirewallEvent {
  final String listName;

  const LoadAddressListByName(this.listName);

  @override
  List<Object?> get props => [listName];
}

/// Clear error state
class ClearFirewallError extends FirewallEvent {
  const ClearFirewallError();
}
