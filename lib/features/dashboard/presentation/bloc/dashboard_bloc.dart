import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_system_resources_usecase.dart';
import '../../domain/usecases/get_interfaces_usecase.dart';
import '../../domain/usecases/toggle_interface_usecase.dart';
import '../../domain/usecases/get_ip_addresses_usecase.dart';
import '../../domain/usecases/ip_address_usecases.dart';
import '../../domain/usecases/get_firewall_rules_usecase.dart';
import '../../domain/usecases/toggle_firewall_rule_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetSystemResourcesUseCase getSystemResourcesUseCase;
  final GetInterfacesUseCase getInterfacesUseCase;
  final ToggleInterfaceUseCase toggleInterfaceUseCase;
  final GetIpAddressesUseCase getIpAddressesUseCase;
  final AddIpAddressUseCase addIpAddressUseCase;
  final UpdateIpAddressUseCase updateIpAddressUseCase;
  final RemoveIpAddressUseCase removeIpAddressUseCase;
  final ToggleIpAddressUseCase toggleIpAddressUseCase;
  final GetFirewallRulesUseCase getFirewallRulesUseCase;
  final ToggleFirewallRuleUseCase toggleFirewallRuleUseCase;

  DashboardBloc({
    required this.getSystemResourcesUseCase,
    required this.getInterfacesUseCase,
    required this.toggleInterfaceUseCase,
    required this.getIpAddressesUseCase,
    required this.addIpAddressUseCase,
    required this.updateIpAddressUseCase,
    required this.removeIpAddressUseCase,
    required this.toggleIpAddressUseCase,
    required this.getFirewallRulesUseCase,
    required this.toggleFirewallRuleUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshSystemResources>(_onRefreshSystemResources);
    on<LoadInterfaces>(_onLoadInterfaces);
    on<ToggleInterface>(_onToggleInterface);
    on<LoadIpAddresses>(_onLoadIpAddresses);
    on<AddIpAddress>(_onAddIpAddress);
    on<UpdateIpAddress>(_onUpdateIpAddress);
    on<RemoveIpAddress>(_onRemoveIpAddress);
    on<ToggleIpAddress>(_onToggleIpAddress);
    on<LoadFirewallRules>(_onLoadFirewallRules);
    on<ToggleFirewallRule>(_onToggleFirewallRule);
    on<ClearError>(_onClearError);
  }

  void _onClearError(
    ClearError event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(clearError: true));
    }
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
          // Keep current state, just set error message
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(errorMessage: failure.message));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (systemResource) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(systemResource: systemResource, clearError: true));
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
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(errorMessage: failure.message));
          }
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (interfaces) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(interfaces: interfaces, clearError: true));
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

    result.fold(
      (failure) {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(errorMessage: failure.message));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (success) {
        if (success) {
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
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(errorMessage: failure.message));
          }
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (ipAddresses) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(ipAddresses: ipAddresses, clearError: true));
          }
        } else {
          if (!emit.isDone) {
            emit(DashboardLoaded(ipAddresses: ipAddresses));
          }
        }
      },
    );
  }

  Future<void> _onAddIpAddress(
    AddIpAddress event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await addIpAddressUseCase(
      address: event.address,
      interfaceName: event.interfaceName,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(errorMessage: failure.message));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (success) {
        if (success) {
          add(const LoadIpAddresses());
        }
      },
    );
  }

  Future<void> _onUpdateIpAddress(
    UpdateIpAddress event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await updateIpAddressUseCase(
      id: event.id,
      address: event.address,
      interfaceName: event.interfaceName,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(errorMessage: failure.message));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (success) {
        if (success) {
          add(const LoadIpAddresses());
        }
      },
    );
  }

  Future<void> _onRemoveIpAddress(
    RemoveIpAddress event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await removeIpAddressUseCase(event.id);

    result.fold(
      (failure) {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(errorMessage: failure.message));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (success) {
        if (success) {
          add(const LoadIpAddresses());
        }
      },
    );
  }

  Future<void> _onToggleIpAddress(
    ToggleIpAddress event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await toggleIpAddressUseCase(event.id, event.enable);

    result.fold(
      (failure) {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(currentState.copyWith(errorMessage: failure.message));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (success) {
        if (success) {
          add(const LoadIpAddresses());
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
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(errorMessage: failure.message));
          }
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (firewallRules) async {
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(firewallRules: firewallRules, clearError: true));
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
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(errorMessage: failure.message));
          }
        } else {
          if (!emit.isDone) {
            emit(DashboardError(failure.message));
          }
        }
      },
      (success) async {
        if (success) {
          // Reload firewall rules
          add(const LoadFirewallRules());
        }
      },
    );
  }
}
