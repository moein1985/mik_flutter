import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_wireless_interfaces_usecase.dart';
import '../../domain/usecases/get_wireless_registrations_usecase.dart';
import '../../domain/usecases/get_security_profiles_usecase.dart';
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
}