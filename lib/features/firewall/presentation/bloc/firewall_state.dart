import 'package:equatable/equatable.dart';
import '../../domain/entities/firewall_rule.dart';

/// Sealed class for FirewallState - provides exhaustive pattern matching
sealed class FirewallState extends Equatable {
  const FirewallState();

  /// Get current data from any state (for exhaustive handling)
  FirewallLoaded? get currentData => switch (this) {
    FirewallInitial() => null,
    FirewallLoading(:final previousData) => previousData,
    FirewallLoaded() => this as FirewallLoaded,
    FirewallError(:final previousData) => previousData,
    FirewallOperationSuccess(:final previousData) => previousData,
  };

  @override
  List<Object?> get props => [];
}

class FirewallInitial extends FirewallState {
  const FirewallInitial();
}

class FirewallLoading extends FirewallState {
  final FirewallRuleType? type;
  final FirewallLoaded? previousData;
  
  const FirewallLoading({this.type, this.previousData});

  @override
  List<Object?> get props => [type, previousData];
}

class FirewallLoaded extends FirewallState {
  /// Rules grouped by type
  final Map<FirewallRuleType, List<FirewallRule>> rulesByType;
  
  /// List of unique address list names for filtering
  final List<String> addressListNames;
  
  /// Currently selected address list name
  final String? selectedAddressListName;
  
  /// Currently loading type (for partial refresh)
  final FirewallRuleType? loadingType;

  const FirewallLoaded({
    this.rulesByType = const {},
    this.addressListNames = const [],
    this.selectedAddressListName,
    this.loadingType,
  });

  /// Get rules for a specific type
  List<FirewallRule> getRulesForType(FirewallRuleType type) {
    return rulesByType[type] ?? [];
  }

  /// Get count of active rules for a type
  int getActiveCount(FirewallRuleType type) {
    return getRulesForType(type).where((r) => !r.disabled).length;
  }

  /// Get count of disabled rules for a type
  int getDisabledCount(FirewallRuleType type) {
    return getRulesForType(type).where((r) => r.disabled).length;
  }

  /// Get total count of rules for a type
  int getTotalCount(FirewallRuleType type) {
    return getRulesForType(type).length;
  }

  FirewallLoaded copyWith({
    Map<FirewallRuleType, List<FirewallRule>>? rulesByType,
    List<String>? addressListNames,
    String? selectedAddressListName,
    FirewallRuleType? loadingType,
    bool clearLoadingType = false,
    bool clearSelectedAddressListName = false,
  }) {
    return FirewallLoaded(
      rulesByType: rulesByType ?? this.rulesByType,
      addressListNames: addressListNames ?? this.addressListNames,
      selectedAddressListName: clearSelectedAddressListName 
          ? null 
          : (selectedAddressListName ?? this.selectedAddressListName),
      loadingType: clearLoadingType ? null : (loadingType ?? this.loadingType),
    );
  }

  @override
  List<Object?> get props => [rulesByType, addressListNames, selectedAddressListName, loadingType];
}

class FirewallError extends FirewallState {
  final String message;
  final FirewallLoaded? previousData;

  const FirewallError(this.message, {this.previousData});

  @override
  List<Object?> get props => [message, previousData];
}

class FirewallOperationSuccess extends FirewallState {
  final String message;
  final FirewallLoaded? previousData;

  const FirewallOperationSuccess(this.message, {this.previousData});

  @override
  List<Object?> get props => [message, previousData];
}
