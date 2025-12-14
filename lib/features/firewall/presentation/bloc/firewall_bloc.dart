import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/firewall_rule.dart';
import '../../domain/usecases/get_firewall_rules.dart';
import '../../domain/usecases/toggle_firewall_rule.dart';
import '../../domain/usecases/get_address_list_names.dart';
import '../../domain/usecases/get_address_list_by_name.dart';
import 'firewall_event.dart';
import 'firewall_state.dart';

class FirewallBloc extends Bloc<FirewallEvent, FirewallState> {
  final _log = AppLogger.tag('FirewallBloc');

  final GetFirewallRulesUseCase getFirewallRulesUseCase;
  final ToggleFirewallRuleUseCase toggleFirewallRuleUseCase;
  final GetAddressListNamesUseCase getAddressListNamesUseCase;
  final GetAddressListByNameUseCase getAddressListByNameUseCase;

  FirewallBloc({
    required this.getFirewallRulesUseCase,
    required this.toggleFirewallRuleUseCase,
    required this.getAddressListNamesUseCase,
    required this.getAddressListByNameUseCase,
  }) : super(const FirewallInitial()) {
    on<LoadFirewallRules>(_onLoadFirewallRules);
    on<ToggleFirewallRule>(_onToggleFirewallRule);
    on<LoadAddressListNames>(_onLoadAddressListNames);
    on<LoadAddressListByName>(_onLoadAddressListByName);
    on<ClearFirewallError>(_onClearFirewallError);
  }

  Future<void> _onLoadFirewallRules(
    LoadFirewallRules event,
    Emitter<FirewallState> emit,
  ) async {
    _log.i('Loading firewall rules for type: ${event.type.displayName}');

    // Get current data from any state
    final currentData = _getCurrentData();

    // Emit loading state with type indicator
    emit(currentData.copyWith(loadingType: event.type));

    final result = await getFirewallRulesUseCase.call(event.type);

    result.fold(
      (failure) {
        _log.e('Failed to load firewall rules: ${failure.message}');
        emit(FirewallError(
          failure.message,
          previousData: currentData,
        ));
      },
      (rules) {
        _log.i('Loaded ${rules.length} ${event.type.displayName} rules');
        
        // Update the rules map
        final updatedRules = Map<FirewallRuleType, List<FirewallRule>>.from(
          currentData.rulesByType,
        );
        updatedRules[event.type] = rules;

        emit(currentData.copyWith(
          rulesByType: updatedRules,
          clearLoadingType: true,
        ));
      },
    );
  }

  Future<void> _onToggleFirewallRule(
    ToggleFirewallRule event,
    Emitter<FirewallState> emit,
  ) async {
    final action = event.enable ? 'Enabling' : 'Disabling';
    _log.i('$action ${event.type.displayName} rule: ${event.id}');

    // Get current data from any state
    final currentData = _getCurrentData();

    // Emit loading state
    emit(currentData.copyWith(loadingType: event.type));

    final result = await toggleFirewallRuleUseCase.call(
      type: event.type,
      id: event.id,
      enable: event.enable,
    );

    result.fold(
      (failure) {
        _log.e('Failed to toggle firewall rule: ${failure.message}');
        emit(FirewallError(
          failure.message,
          previousData: currentData,
        ));
      },
      (success) {
        final actionDone = event.enable ? 'enabled' : 'disabled';
        _log.i('Rule $actionDone successfully');

        // Update the rule in local state for immediate UI feedback
        final updatedRules = Map<FirewallRuleType, List<FirewallRule>>.from(
          currentData.rulesByType,
        );
        
        if (updatedRules.containsKey(event.type)) {
          updatedRules[event.type] = updatedRules[event.type]!.map((rule) {
            if (rule.id == event.id) {
              return rule.copyWith(disabled: !event.enable);
            }
            return rule;
          }).toList();
        }

        emit(FirewallOperationSuccess(
          'Rule $actionDone successfully',
          previousData: currentData.copyWith(
            rulesByType: updatedRules,
            clearLoadingType: true,
          ),
        ));
      },
    );
  }

  Future<void> _onLoadAddressListNames(
    LoadAddressListNames event,
    Emitter<FirewallState> emit,
  ) async {
    _log.i('Loading address list names');

    final currentData = _getCurrentData();

    final result = await getAddressListNamesUseCase.call();

    result.fold(
      (failure) {
        _log.e('Failed to load address list names: ${failure.message}');
        emit(FirewallError(
          failure.message,
          previousData: currentData,
        ));
      },
      (names) {
        _log.i('Loaded ${names.length} address list names');
        emit(currentData.copyWith(addressListNames: names));
      },
    );
  }

  Future<void> _onLoadAddressListByName(
    LoadAddressListByName event,
    Emitter<FirewallState> emit,
  ) async {
    _log.i('Loading address list entries for: ${event.listName}');

    final currentData = _getCurrentData();

    // Emit loading state
    emit(currentData.copyWith(loadingType: FirewallRuleType.addressList));

    final result = await getAddressListByNameUseCase.call(event.listName);

    result.fold(
      (failure) {
        _log.e('Failed to load address list by name: ${failure.message}');
        emit(FirewallError(
          failure.message,
          previousData: currentData,
        ));
      },
      (rules) {
        _log.i('Loaded ${rules.length} entries for list: ${event.listName}');
        
        // Update the rules map for address list
        final updatedRules = Map<FirewallRuleType, List<FirewallRule>>.from(
          currentData.rulesByType,
        );
        updatedRules[FirewallRuleType.addressList] = rules;

        emit(currentData.copyWith(
          rulesByType: updatedRules,
          clearLoadingType: true,
          selectedAddressListName: event.listName,
        ));
      },
    );
  }

  /// Helper method to get current data from any state using sealed class pattern matching
  FirewallLoaded _getCurrentData() {
    return state.currentData ?? const FirewallLoaded();
  }

  void _onClearFirewallError(
    ClearFirewallError event,
    Emitter<FirewallState> emit,
  ) {
    final data = state.currentData;
    if (data != null) {
      emit(data);
    } else {
      emit(const FirewallLoaded());
    }
  }
}
