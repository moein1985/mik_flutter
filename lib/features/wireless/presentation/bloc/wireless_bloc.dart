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
import '../../domain/usecases/update_wireless_ssid_usecase.dart';
import '../../domain/usecases/get_wireless_password_usecase.dart';
import '../../domain/usecases/update_wireless_password_usecase.dart';
import '../../domain/usecases/add_virtual_wireless_interface_usecase.dart';
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
  final UpdateWirelessSsidUseCase updateWirelessSsidUseCase;
  final GetWirelessPasswordUseCase getWirelessPasswordUseCase;
  final UpdateWirelessPasswordUseCase updateWirelessPasswordUseCase;
  final AddVirtualWirelessInterfaceUseCase addVirtualWirelessInterfaceUseCase;

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
    required this.updateWirelessSsidUseCase,
    required this.getWirelessPasswordUseCase,
    required this.updateWirelessPasswordUseCase,
    required this.addVirtualWirelessInterfaceUseCase,
  }) : super(WirelessState.initial()) {
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
    on<UpdateWirelessSsid>(_onUpdateWirelessSsid);
    on<GetWirelessPassword>(_onGetWirelessPassword);
    on<UpdateWirelessPassword>(_onUpdateWirelessPassword);
    on<AddVirtualWirelessInterface>(_onAddVirtualWirelessInterface);
  }

  Future<void> _onLoadWirelessInterfaces(
    LoadWirelessInterfaces event,
    Emitter<WirelessState> emit,
  ) async {
    emit(state.copyWith(interfacesLoading: true, clearInterfacesError: true));
    try {
      final result = await getWirelessInterfacesUseCase.call();
      result.fold(
        (failure) => emit(state.copyWith(interfacesLoading: false, interfacesError: failure.message)),
        (interfaces) => emit(state.copyWith(interfacesLoading: false, interfaces: interfaces)),
      );
    } on TimeoutException catch (e) {
      emit(state.copyWith(interfacesLoading: false, interfacesError: 'Connection timeout. Please try again.'));
    } catch (e) {
      emit(state.copyWith(interfacesLoading: false, interfacesError: e.toString()));
    }
  }

  Future<void> _onEnableWirelessInterface(
    EnableWirelessInterface event,
    Emitter<WirelessState> emit,
  ) async {
    if (event.interfaceId.isEmpty) {
      emit(state.copyWith(operationError: 'Interface ID is empty. Try refreshing the list.'));
      return;
    }
    final result = await enableWirelessInterfaceUseCase.call(event.interfaceId);
    result.fold(
      (failure) => emit(state.copyWith(operationError: failure.message)),
      (_) {
        emit(state.copyWith(operationSuccess: 'Wireless interface enabled successfully'));
        add(const LoadWirelessInterfaces());
      },
    );
  }

  Future<void> _onDisableWirelessInterface(
    DisableWirelessInterface event,
    Emitter<WirelessState> emit,
  ) async {
    if (event.interfaceId.isEmpty) {
      emit(state.copyWith(operationError: 'Interface ID is empty. Try refreshing the list.'));
      return;
    }
    final result = await disableWirelessInterfaceUseCase.call(event.interfaceId);
    result.fold(
      (failure) => emit(state.copyWith(operationError: failure.message)),
      (_) {
        emit(state.copyWith(operationSuccess: 'Wireless interface disabled successfully'));
        add(const LoadWirelessInterfaces());
      },
    );
  }

  Future<void> _onLoadWirelessRegistrations(
    LoadWirelessRegistrations event,
    Emitter<WirelessState> emit,
  ) async {
    emit(state.copyWith(registrationsLoading: true, clearRegistrationsError: true));
    try {
      final result = await getWirelessRegistrationsUseCase.call();
      result.fold(
        (failure) => emit(state.copyWith(registrationsLoading: false, registrationsError: failure.message)),
        (registrations) => emit(state.copyWith(registrationsLoading: false, registrations: registrations)),
      );
    } catch (e) {
      emit(state.copyWith(registrationsLoading: false, registrationsError: e.toString()));
    }
  }

  Future<void> _onLoadRegistrationsByInterface(
    LoadRegistrationsByInterface event,
    Emitter<WirelessState> emit,
  ) async {
    emit(state.copyWith(registrationsLoading: true, clearRegistrationsError: true));
    final result = await getRegistrationsByInterfaceUseCase.call(event.interfaceName);
    result.fold(
      (failure) => emit(state.copyWith(registrationsLoading: false, registrationsError: failure.message)),
      (registrations) => emit(state.copyWith(registrationsLoading: false, registrations: registrations)),
    );
  }

  Future<void> _onDisconnectWirelessClient(
    DisconnectWirelessClient event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await disconnectClientUseCase.call(event.macAddress, event.interfaceName);
    result.fold(
      (failure) => emit(state.copyWith(operationError: failure.message)),
      (_) {
        emit(state.copyWith(operationSuccess: 'Wireless client disconnected successfully'));
        add(const LoadWirelessRegistrations());
      },
    );
  }

  Future<void> _onLoadSecurityProfiles(
    LoadSecurityProfiles event,
    Emitter<WirelessState> emit,
  ) async {
    emit(state.copyWith(profilesLoading: true, clearProfilesError: true));
    try {
      final result = await getSecurityProfilesUseCase.call();
      result.fold(
        (failure) => emit(state.copyWith(profilesLoading: false, profilesError: failure.message)),
        (profiles) => emit(state.copyWith(profilesLoading: false, profiles: profiles)),
      );
    } catch (e) {
      emit(state.copyWith(profilesLoading: false, profilesError: e.toString()));
    }
  }

  Future<void> _onCreateSecurityProfile(
    CreateSecurityProfile event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await createSecurityProfileUseCase.call(event.profile);
    result.fold(
      (failure) => emit(state.copyWith(operationError: failure.message)),
      (_) {
        emit(state.copyWith(operationSuccess: 'Security profile created successfully'));
        add(const LoadSecurityProfiles());
      },
    );
  }

  Future<void> _onUpdateSecurityProfile(
    UpdateSecurityProfile event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await updateSecurityProfileUseCase.call(event.profile);
    result.fold(
      (failure) => emit(state.copyWith(operationError: failure.message)),
      (_) {
        emit(state.copyWith(operationSuccess: 'Security profile updated successfully'));
        add(const LoadSecurityProfiles());
      },
    );
  }

  Future<void> _onDeleteSecurityProfile(
    DeleteSecurityProfile event,
    Emitter<WirelessState> emit,
  ) async {
    final result = await deleteSecurityProfileUseCase.call(event.profileId);
    result.fold(
      (failure) => emit(state.copyWith(operationError: failure.message)),
      (_) {
        emit(state.copyWith(operationSuccess: 'Security profile deleted successfully'));
        add(const LoadSecurityProfiles());
      },
    );
  }

  Future<void> _onScanWirelessNetworks(
    ScanWirelessNetworks event,
    Emitter<WirelessState> emit,
  ) async {
    emit(state.copyWith(scanLoading: true, clearScanError: true));
    try {
      final result = await scanWirelessNetworksUseCase.call(
        interfaceId: event.interfaceId,
        duration: event.duration,
      );
      result.fold(
        (failure) => emit(state.copyWith(scanLoading: false, scanError: failure.message)),
        (scanResults) => emit(state.copyWith(scanLoading: false, scanResults: scanResults)),
      );
    } catch (e) {
      emit(state.copyWith(scanLoading: false, scanError: e.toString()));
    }
  }

  Future<void> _onLoadAccessList(
    LoadAccessList event,
    Emitter<WirelessState> emit,
  ) async {
    emit(state.copyWith(accessListLoading: true, clearAccessListError: true));
    try {
      final result = await getAccessListUseCase.call();
      result.fold(
        (failure) => emit(state.copyWith(accessListLoading: false, accessListError: failure.message)),
        (accessList) => emit(state.copyWith(accessListLoading: false, accessList: accessList)),
      );
    } catch (e) {
      emit(state.copyWith(accessListLoading: false, accessListError: e.toString()));
    }
  }

  Future<void> _onAddAccessListEntry(
    AddAccessListEntry event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await addAccessListEntryUseCase.call(event.entry);
      result.fold(
        (failure) => emit(state.copyWith(operationError: failure.message)),
        (_) {
          emit(state.copyWith(operationSuccess: 'Access list entry added successfully'));
          add(const LoadAccessList());
        },
      );
    } catch (e) {
      emit(state.copyWith(operationError: e.toString()));
    }
  }

  Future<void> _onRemoveAccessListEntry(
    RemoveAccessListEntry event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await removeAccessListEntryUseCase.call(event.id);
      result.fold(
        (failure) => emit(state.copyWith(operationError: failure.message)),
        (_) {
          emit(state.copyWith(operationSuccess: 'Access list entry removed successfully'));
          add(const LoadAccessList());
        },
      );
    } catch (e) {
      emit(state.copyWith(operationError: e.toString()));
    }
  }

  Future<void> _onUpdateAccessListEntry(
    UpdateAccessListEntry event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await updateAccessListEntryUseCase.call(event.entry);
      result.fold(
        (failure) => emit(state.copyWith(operationError: failure.message)),
        (_) {
          emit(state.copyWith(operationSuccess: 'Access list entry updated successfully'));
          add(const LoadAccessList());
        },
      );
    } catch (e) {
      emit(state.copyWith(operationError: e.toString()));
    }
  }

  Future<void> _onUpdateWirelessSsid(
    UpdateWirelessSsid event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await updateWirelessSsidUseCase.call(event.interfaceId, event.newSsid);
      result.fold(
        (failure) => emit(state.copyWith(operationError: failure.message)),
        (_) {
          emit(state.copyWith(operationSuccess: 'WiFi name updated successfully'));
        },
      );
      // If successful, wait a bit for the interface to stabilize then reload
      if (result.isRight()) {
        await Future.delayed(const Duration(milliseconds: 500));
        add(const LoadWirelessInterfaces());
      }
    } catch (e) {
      emit(state.copyWith(operationError: e.toString()));
    }
  }

  Future<void> _onGetWirelessPassword(
    GetWirelessPassword event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await getWirelessPasswordUseCase.call(event.securityProfileName);
      result.fold(
        (failure) => emit(state.copyWith(operationError: failure.message)),
        (password) {
          // Password will be handled in the UI via BlocListener
          emit(state.copyWith(operationSuccess: 'PASSWORD:$password'));
        },
      );
    } catch (e) {
      emit(state.copyWith(operationError: e.toString()));
    }
  }

  Future<void> _onUpdateWirelessPassword(
    UpdateWirelessPassword event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      final result = await updateWirelessPasswordUseCase.call(
        event.securityProfileName,
        event.newPassword,
      );
      result.fold(
        (failure) => emit(state.copyWith(operationError: failure.message)),
        (_) {
          emit(state.copyWith(operationSuccess: 'WiFi password updated successfully'));
        },
      );
    } catch (e) {
      emit(state.copyWith(operationError: e.toString()));
    }
  }

  Future<void> _onAddVirtualWirelessInterface(
    AddVirtualWirelessInterface event,
    Emitter<WirelessState> emit,
  ) async {
    try {
      emit(state.copyWith(interfacesLoading: true));
      final result = await addVirtualWirelessInterfaceUseCase.call(
        ssid: event.ssid,
        masterInterface: event.masterInterface,
        name: event.name,
        securityProfile: event.securityProfile,
        disabled: !event.enabled,
      );
      result.fold(
        (failure) {
          emit(state.copyWith(
            interfacesLoading: false,
            operationError: failure.message,
          ));
        },
        (_) async {
          emit(state.copyWith(
            interfacesLoading: false,
            operationSuccess: 'Virtual WiFi interface created successfully',
          ));
          // Small delay to allow RouterOS to fully register the new interface
          await Future.delayed(const Duration(milliseconds: 500));
          add(const LoadWirelessInterfaces());
        },
      );
    } catch (e) {
      emit(state.copyWith(
        interfacesLoading: false,
        operationError: e.toString(),
      ));
    }
  }
}
