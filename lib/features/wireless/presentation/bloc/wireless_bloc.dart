import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_wireless_interfaces_usecase.dart';
import '../../domain/usecases/get_wireless_registrations_usecase.dart';
import '../../domain/usecases/get_security_profiles_usecase.dart';
import '../../domain/usecases/scan_wireless_networks_usecase.dart';
import '../../domain/usecases/get_access_list_usecase.dart';
import '../../domain/usecases/add_access_list_entry_usecase.dart';
import '../../domain/usecases/remove_access_list_entry_usecase.dart';
import '../../domain/usecases/update_access_list_entry_usecase.dart';
import 'wireless_event.dart';
import 'wireless_state.dart';

class WirelessBloc extends Bloc<WirelessEvent, WirelessState> {
  final GetWirelessInterfacesUseCase getWirelessInterfacesUseCase;
  final GetWirelessRegistrationsUseCase getWirelessRegistrationsUseCase;
  final GetRegistrationsByInterfaceUseCase getRegistrationsByInterfaceUseCase;
  final DisconnectClientUseCase disconnectClientUseCase;
  final GetSecurityProfilesUseCase getSecurityProfilesUseCase;
  final EnableWirelessInterfaceUseCase enableWirelessInterfaceUseCase;
  final DisableWirelessInterfaceUseCase disableWirelessInterfaceUseCase;
  final CreateSecurityProfileUseCase createSecurityProfileUseCase;
  final UpdateSecurityProfileUseCase updateSecurityProfileUseCase;
  final DeleteSecurityProfileUseCase deleteSecurityProfileUseCase;
  final ScanWirelessNetworksUseCase scanWirelessNetworksUseCase;
  final GetAccessListUseCase getAccessListUseCase;
  final AddAccessListEntryUseCase addAccessListEntryUseCase;
  final RemoveAccessListEntryUseCase removeAccessListEntryUseCase;
  final UpdateAccessListEntryUseCase updateAccessListEntryUseCase;

  WirelessBloc({
    required this.getWirelessInterfacesUseCase,
    required this.getWirelessRegistrationsUseCase,
    required this.getRegistrationsByInterfaceUseCase,
    required this.disconnectClientUseCase,
    required this.getSecurityProfilesUseCase,
    required this.enableWirelessInterfaceUseCase,
    required this.disableWirelessInterfaceUseCase,
    required this.createSecurityProfileUseCase,
    required this.updateSecurityProfileUseCase,
    required this.deleteSecurityProfileUseCase,
    required this.scanWirelessNetworksUseCase,
    required this.getAccessListUseCase,
    required this.addAccessListEntryUseCase,
    required this.removeAccessListEntryUseCase,
    required this.updateAccessListEntryUseCase,
  }) : super(const WirelessInitial()) {
    on<LoadWirelessInterfaces>(_onLoadWirelessInterfaces);
    on<EnableWirelessInterface>(_onEnableWirelessInterface);
    on<DisableWirelessInterface>(_onDisableWirelessInterface);
    on<LoadWirelessRegistrations>(_onLoadWirelessRegistrations);
    on<LoadRegistrationsByInterface>(_onLoadRegistrationsByInterface);
    on<DisconnectWirelessClient>(_onDisconnectWirelessClient);
    on<LoadSecurityProfiles>(_onLoadSecurityProfiles);
    on<CreateSecurityProfile>(_onCreateSecurityProfile);
    on<UpdateSecurityProfile>(_onUpdateSecurityProfile);
    on<DeleteSecurityProfile>(_onDeleteSecurityProfile);
    on<ScanWirelessNetworks>(_onScanWirelessNetworks);
    on<LoadAccessList>(_onLoadAccessList);
    on<AddAccessListEntry>(_onAddAccessListEntry);
    on<RemoveAccessListEntry>(_onRemoveAccessListEntry);
    on<UpdateAccessListEntry>(_onUpdateAccessListEntry);
  }

  Future<void> _onLoadWirelessInterfaces(
    LoadWirelessInterfaces event,
    Emitter<WirelessState> emit,
  ) async {
    emit(const WirelessInterfacesLoading());
    try {
      final result = await getWirelessInterfacesUseCase.call();
      result.fold(
        (failure) => emit(WirelessInterfacesError(failure.message)),
        (interfaces) => emit(WirelessInterfacesLoaded(interfaces)),
      );
    } catch (e) {
      emit(WirelessInterfacesError('Failed to load wireless interfaces: ${e.toString()}'));
    }
  }

  Future<void> _onEnableWirelessInterface(
    EnableWirelessInterface event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await enableWirelessInterfaceUseCase.call(event.interfaceId);
    result.fold(
      (failure) => emit(WirelessOperationError(failure.message)),
      (_) {
        emit(const WirelessOperationSuccess('Wireless interface enabled successfully'));
        add(const LoadWirelessInterfaces()); // Reload the list
      },
    );
  }

  Future<void> _onDisableWirelessInterface(
    DisableWirelessInterface event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await disableWirelessInterfaceUseCase.call(event.interfaceId);
    result.fold(
      (failure) => emit(WirelessOperationError(failure.message)),
      (_) {
        emit(const WirelessOperationSuccess('Wireless interface disabled successfully'));
        add(const LoadWirelessInterfaces()); // Reload the list
      },
    );
  }

  Future<void> _onLoadWirelessRegistrations(
    LoadWirelessRegistrations event,
    Emitter<WirelessState> emit,
  ) async {
    emit(const WirelessRegistrationsLoading());
    try {
      final result = await getWirelessRegistrationsUseCase.call();
      result.fold(
        (failure) => emit(WirelessRegistrationsError(failure.message)),
        (registrations) => emit(WirelessRegistrationsLoaded(registrations)),
      );
    } catch (e) {
      emit(WirelessRegistrationsError('Failed to load wireless registrations: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRegistrationsByInterface(
    LoadRegistrationsByInterface event,
    Emitter<WirelessState> emit,
  ) async {
    emit(const WirelessRegistrationsLoading());
    final result = await getRegistrationsByInterfaceUseCase.call(event.interfaceName);
    result.fold(
      (failure) => emit(WirelessRegistrationsError(failure.message)),
      (registrations) => emit(WirelessRegistrationsLoaded(registrations)),
    );
  }

  Future<void> _onDisconnectWirelessClient(
    DisconnectWirelessClient event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await disconnectClientUseCase.call(event.macAddress, event.interfaceName);
    result.fold(
      (failure) => emit(WirelessOperationError(failure.message)),
      (_) {
        emit(const WirelessOperationSuccess('Wireless client disconnected successfully'));
        add(const LoadWirelessRegistrations()); // Reload the list
      },
    );
  }

  Future<void> _onLoadSecurityProfiles(
    LoadSecurityProfiles event,
    Emitter<WirelessState> emit,
  ) async {
    emit(const SecurityProfilesLoading());
    final result = await getSecurityProfilesUseCase.call();
    result.fold(
      (failure) => emit(SecurityProfilesError(failure.message)),
      (profiles) => emit(SecurityProfilesLoaded(profiles)),
    );
  }

  Future<void> _onCreateSecurityProfile(
    CreateSecurityProfile event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await createSecurityProfileUseCase.call(event.profile);
    result.fold(
      (failure) => emit(WirelessOperationError(failure.message)),
      (_) {
        emit(const WirelessOperationSuccess('Security profile created successfully'));
        add(const LoadSecurityProfiles()); // Reload the list
      },
    );
  }

  Future<void> _onUpdateSecurityProfile(
    UpdateSecurityProfile event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await updateSecurityProfileUseCase.call(event.profile);
    result.fold(
      (failure) => emit(WirelessOperationError(failure.message)),
      (_) {
        emit(const WirelessOperationSuccess('Security profile updated successfully'));
        add(const LoadSecurityProfiles()); // Reload the list
      },
    );
  }

  Future<void> _onDeleteSecurityProfile(
    DeleteSecurityProfile event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await deleteSecurityProfileUseCase.call(event.profileId);
    result.fold(
      (failure) => emit(WirelessOperationError(failure.message)),
      (_) {
        emit(const WirelessOperationSuccess('Security profile deleted successfully'));
        add(const LoadSecurityProfiles()); // Reload the list
      },
    );
  }

  Future<void> _onScanWirelessNetworks(
    ScanWirelessNetworks event,
    Emitter<WirelessState> emit,
  ) async {
    emit(const WirelessScanLoading());
    try {
      final result = await scanWirelessNetworksUseCase.call(
        interfaceId: event.interfaceId,
        duration: event.duration,
      );
      result.fold(
        (failure) => emit(WirelessScanError(failure.message)),
        (networks) => emit(WirelessScanLoaded(networks)),
      );
    } catch (e) {
      emit(WirelessScanError('Failed to scan wireless networks: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAccessList(
    LoadAccessList event,
    Emitter<WirelessState> emit,
  ) async {
    emit(const AccessListLoading());
    try {
      final result = await getAccessListUseCase.call();
      result.fold(
        (failure) => emit(AccessListError(failure.message)),
        (accessList) => emit(AccessListLoaded(accessList)),
      );
    } catch (e) {
      emit(AccessListError('Failed to load access list: ${e.toString()}'));
    }
  }

  Future<void> _onAddAccessListEntry(
    AddAccessListEntry event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await addAccessListEntryUseCase.call(event.entry);
      result.fold(
        (failure) => emit(WirelessOperationError(failure.message)),
        (_) {
          emit(const WirelessOperationSuccess('Access list entry added successfully'));
          add(const LoadAccessList());
        },
      );
    } catch (e) {
      emit(WirelessOperationError('Failed to add access list entry: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveAccessListEntry(
    RemoveAccessListEntry event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await removeAccessListEntryUseCase.call(event.id);
      result.fold(
        (failure) => emit(WirelessOperationError(failure.message)),
        (_) {
          emit(const WirelessOperationSuccess('Access list entry removed successfully'));
          add(const LoadAccessList());
        },
      );
    } catch (e) {
      emit(WirelessOperationError('Failed to remove access list entry: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAccessListEntry(
    UpdateAccessListEntry event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await updateAccessListEntryUseCase.call(event.entry);
      result.fold(
        (failure) => emit(WirelessOperationError(failure.message)),
        (_) {
          emit(const WirelessOperationSuccess('Access list entry updated successfully'));
          add(const LoadAccessList());
        },
      );
    } catch (e) {
      emit(WirelessOperationError('Failed to update access list entry: ${e.toString()}'));
    }
  }
}