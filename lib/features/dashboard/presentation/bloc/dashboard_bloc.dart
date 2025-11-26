import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_system_resources_usecase.dart';
import '../../domain/usecases/get_interfaces_usecase.dart';
import '../../domain/usecases/toggle_interface_usecase.dart';
import '../../domain/usecases/get_ip_addresses_usecase.dart';
import '../../domain/usecases/get_firewall_rules_usecase.dart';
import '../../domain/usecases/toggle_firewall_rule_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetSystemResourcesUseCase getSystemResourcesUseCase;
  final GetInterfacesUseCase getInterfacesUseCase;
  final ToggleInterfaceUseCase toggleInterfaceUseCase;
  final GetIpAddressesUseCase getIpAddressesUseCase;
  final GetFirewallRulesUseCase getFirewallRulesUseCase;
  final ToggleFirewallRuleUseCase toggleFirewallRuleUseCase;

  DashboardBloc({
    required this.getSystemResourcesUseCase,
    required this.getInterfacesUseCase,
    required this.toggleInterfaceUseCase,
    required this.getIpAddressesUseCase,
    required this.getFirewallRulesUseCase,
    required this.toggleFirewallRuleUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshSystemResources>(_onRefreshSystemResources);
    on<LoadInterfaces>(_onLoadInterfaces);
    on<ToggleInterface>(_onToggleInterface);
    on<LoadIpAddresses>(_onLoadIpAddresses);
    on<LoadFirewallRules>(_onLoadFirewallRules);
    on<ToggleFirewallRule>(_onToggleFirewallRule);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await getSystemResourcesUseCase();

    await result.fold(
      (failure) async {
        emit(DashboardError(failure.message));
      },
      (systemResource) async {
        emit(DashboardLoaded(systemResource: systemResource));
      },
    );
  }

  Future<void> _onRefreshSystemResources(
    RefreshSystemResources event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getSystemResourcesUseCase();

    await result.fold(
      (failure) async {
        if (state is DashboardLoaded) {
          // Keep current state but show error
          emit(DashboardError(failure.message));
        }
      },
      (systemResource) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(systemResource: systemResource));
        } else {
          emit(DashboardLoaded(systemResource: systemResource));
        }
      },
    );
  }

  Future<void> _onLoadInterfaces(
    LoadInterfaces event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getInterfacesUseCase();

    await result.fold(
      (failure) async {
        emit(DashboardError(failure.message));
      },
      (interfaces) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(interfaces: interfaces));
          }
        } else {
          if (!emit.isDone) {
            emit(DashboardLoaded(interfaces: interfaces));
          }
        }
      },
    );
  }

  Future<void> _onToggleInterface(
    ToggleInterface event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await toggleInterfaceUseCase(event.id, event.enable);

    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(DashboardError(failure.message));
        }
      },
      (success) async {
        if (success) {
          if (!emit.isDone) {
            emit(DashboardOperationSuccess(
              event.enable ? 'Interface enabled' : 'Interface disabled',
            ));
          }
          // Reload interfaces
          add(const LoadInterfaces());
        }
      },
    );
  }

  Future<void> _onLoadIpAddresses(
    LoadIpAddresses event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getIpAddressesUseCase();

    await result.fold(
      (failure) async {
        emit(DashboardError(failure.message));
      },
      (ipAddresses) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(ipAddresses: ipAddresses));
          }
        } else {
          if (!emit.isDone) {
            emit(DashboardLoaded(ipAddresses: ipAddresses));
          }
        }
      },
    );
  }

  Future<void> _onLoadFirewallRules(
    LoadFirewallRules event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getFirewallRulesUseCase();

    await result.fold(
      (failure) async {
        emit(DashboardError(failure.message));
      },
      (firewallRules) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(firewallRules: firewallRules));
          }
        } else {
          if (!emit.isDone) {
            emit(DashboardLoaded(firewallRules: firewallRules));
          }
        }
      },
    );
  }

  Future<void> _onToggleFirewallRule(
    ToggleFirewallRule event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await toggleFirewallRuleUseCase(event.id, event.enable);

    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(DashboardError(failure.message));
        }
      },
      (success) async {
        if (success) {
          if (!emit.isDone) {
            emit(DashboardOperationSuccess(
              event.enable ? 'Rule enabled' : 'Rule disabled',
            ));
          }
          // Reload firewall rules
          add(const LoadFirewallRules());
        }
      },
    );
  }
}
