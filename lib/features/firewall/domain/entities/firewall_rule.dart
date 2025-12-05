import 'package:equatable/equatable.dart';

/// Types of firewall rules
enum FirewallRuleType {
  nat,
  filter,
  mangle,
  raw,
  addressList,
  layer7Protocol,
}

/// Extension to get RouterOS path for each type
extension FirewallRuleTypeExtension on FirewallRuleType {
  String get routerOsPath {
    switch (this) {
      case FirewallRuleType.nat:
        return '/ip/firewall/nat';
      case FirewallRuleType.filter:
        return '/ip/firewall/filter';
      case FirewallRuleType.mangle:
        return '/ip/firewall/mangle';
      case FirewallRuleType.raw:
        return '/ip/firewall/raw';
      case FirewallRuleType.addressList:
        return '/ip/firewall/address-list';
      case FirewallRuleType.layer7Protocol:
        return '/ip/firewall/layer7-protocol';
    }
  }
  
  String get displayName {
    switch (this) {
      case FirewallRuleType.nat:
        return 'NAT';
      case FirewallRuleType.filter:
        return 'Filter';
      case FirewallRuleType.mangle:
        return 'Mangle';
      case FirewallRuleType.raw:
        return 'Raw';
      case FirewallRuleType.addressList:
        return 'Address List';
      case FirewallRuleType.layer7Protocol:
        return 'Layer7 Protocol';
    }
  }
}

/// Firewall rule entity that holds all dynamic fields from RouterOS
class FirewallRule extends Equatable {
  /// Internal RouterOS ID (e.g., *0, *1, *2)
  final String id;
  
  /// Rule type (nat, filter, mangle, raw, address-list, layer7-protocol)
  final FirewallRuleType type;
  
  /// Whether the rule is disabled
  final bool disabled;
  
  /// Whether the rule is dynamic (created by RouterOS)
  final bool dynamic;
  
  /// Whether the rule is invalid
  final bool invalid;
  
  /// Chain (for nat, filter, mangle, raw)
  final String? chain;
  
  /// Action (for nat, filter, mangle, raw)
  final String? action;
  
  /// List name (for address-list)
  final String? listName;
  
  /// Protocol name (for layer7-protocol)
  final String? protocolName;
  
  /// Regexp pattern (for layer7-protocol)
  final String? regexp;
  
  /// All raw parameters from RouterOS response
  /// This contains every field returned by RouterOS
  final Map<String, String> allParameters;

  const FirewallRule({
    required this.id,
    required this.type,
    required this.disabled,
    this.dynamic = false,
    this.invalid = false,
    this.chain,
    this.action,
    this.listName,
    this.protocolName,
    this.regexp,
    required this.allParameters,
  });

  /// Get a specific parameter value
  String? getParameter(String key) => allParameters[key];
  
  /// Get display title for the rule
  String get displayTitle {
    switch (type) {
      case FirewallRuleType.addressList:
        return listName ?? 'Unknown List';
      case FirewallRuleType.layer7Protocol:
        return protocolName ?? 'Unknown Protocol';
      default:
        return '${chain ?? 'unknown'} → ${action ?? 'unknown'}';
    }
  }
  
  /// Get short summary for collapsed view
  String get summary {
    final parts = <String>[];
    
    // Add key parameters based on type
    if (type == FirewallRuleType.addressList) {
      final address = allParameters['address'];
      final timeout = allParameters['timeout'];
      if (address != null) parts.add('Address: $address');
      if (timeout != null) parts.add('Timeout: $timeout');
    } else if (type == FirewallRuleType.layer7Protocol) {
      final regexp = allParameters['regexp'];
      if (regexp != null) {
        parts.add('Pattern: ${regexp.length > 30 ? '${regexp.substring(0, 30)}...' : regexp}');
      }
    } else {
      // For nat, filter, mangle, raw
      final srcAddress = allParameters['src-address'] ?? allParameters['src-address-list'];
      final dstAddress = allParameters['dst-address'] ?? allParameters['dst-address-list'];
      final protocol = allParameters['protocol'];
      
      if (srcAddress != null) parts.add('Src: $srcAddress');
      if (dstAddress != null) parts.add('Dst: $dstAddress');
      if (protocol != null) parts.add('Proto: $protocol');
    }
    
    return parts.isEmpty ? 'No details' : parts.join(' | ');
  }
  
  /// Get all parameters for expanded view, excluding internal ones
  Map<String, String> get displayParameters {
    final excluded = {'.id', 'type', 'disabled', 'dynamic', 'invalid'};
    return Map.fromEntries(
      allParameters.entries.where((e) => !excluded.contains(e.key))
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        disabled,
        dynamic,
        invalid,
        chain,
        action,
        listName,
        protocolName,
        allParameters,
      ];

  FirewallRule copyWith({
    String? id,
    FirewallRuleType? type,
    bool? disabled,
    bool? dynamic,
    bool? invalid,
    String? chain,
    String? action,
    String? listName,
    String? protocolName,
    String? regexp,
    Map<String, String>? allParameters,
  }) {
    return FirewallRule(
      id: id ?? this.id,
      type: type ?? this.type,
      disabled: disabled ?? this.disabled,
      dynamic: dynamic ?? this.dynamic,
      invalid: invalid ?? this.invalid,
      chain: chain ?? this.chain,
      action: action ?? this.action,
      listName: listName ?? this.listName,
      protocolName: protocolName ?? this.protocolName,
      regexp: regexp ?? this.regexp,
      allParameters: allParameters ?? this.allParameters,
    );
  }
}
