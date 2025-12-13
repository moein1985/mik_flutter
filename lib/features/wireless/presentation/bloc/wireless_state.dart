import 'package:equatable/equatable.dart';
import '../../domain/entities/access_list_entry.dart';
import '../../domain/entities/wireless_scan_result.dart';

/// Unified state that holds ALL wireless data
/// This prevents state loss when switching tabs
class WirelessState extends Equatable {
  // Interfaces
  final bool interfacesLoading;
  final List<dynamic> interfaces;
  final String? interfacesError;

  // Registrations (Clients)
  final bool registrationsLoading;
  final List<dynamic> registrations;
  final String? registrationsError;

  // Security Profiles
  final bool profilesLoading;
  final List<dynamic> profiles;
  final String? profilesError;

  // Scanner
  final bool scanLoading;
  final List<WirelessScanResult> scanResults;
  final String? scanError;

  // Access List
  final bool accessListLoading;
  final List<AccessListEntry> accessList;
  final String? accessListError;

  // Operation status
  final String? operationSuccess;
  final String? operationError;

  const WirelessState({
    this.interfacesLoading = false,
    this.interfaces = const [],
    this.interfacesError,
    this.registrationsLoading = false,
    this.registrations = const [],
    this.registrationsError,
    this.profilesLoading = false,
    this.profiles = const [],
    this.profilesError,
    this.scanLoading = false,
    this.scanResults = const [],
    this.scanError,
    this.accessListLoading = false,
    this.accessList = const [],
    this.accessListError,
    this.operationSuccess,
    this.operationError,
  });

  /// Initial state
  factory WirelessState.initial() => const WirelessState();

  /// Copy with helper for immutable updates
  WirelessState copyWith({
    bool? interfacesLoading,
    List<dynamic>? interfaces,
    String? interfacesError,
    bool clearInterfacesError = false,
    bool? registrationsLoading,
    List<dynamic>? registrations,
    String? registrationsError,
    bool clearRegistrationsError = false,
    bool? profilesLoading,
    List<dynamic>? profiles,
    String? profilesError,
    bool clearProfilesError = false,
    bool? scanLoading,
    List<WirelessScanResult>? scanResults,
    String? scanError,
    bool clearScanError = false,
    bool? accessListLoading,
    List<AccessListEntry>? accessList,
    String? accessListError,
    bool clearAccessListError = false,
    String? operationSuccess,
    String? operationError,
    bool clearOperationStatus = false,
  }) {
    return WirelessState(
      interfacesLoading: interfacesLoading ?? this.interfacesLoading,
      interfaces: interfaces ?? this.interfaces,
      interfacesError: clearInterfacesError ? null : (interfacesError ?? this.interfacesError),
      registrationsLoading: registrationsLoading ?? this.registrationsLoading,
      registrations: registrations ?? this.registrations,
      registrationsError: clearRegistrationsError ? null : (registrationsError ?? this.registrationsError),
      profilesLoading: profilesLoading ?? this.profilesLoading,
      profiles: profiles ?? this.profiles,
      profilesError: clearProfilesError ? null : (profilesError ?? this.profilesError),
      scanLoading: scanLoading ?? this.scanLoading,
      scanResults: scanResults ?? this.scanResults,
      scanError: clearScanError ? null : (scanError ?? this.scanError),
      accessListLoading: accessListLoading ?? this.accessListLoading,
      accessList: accessList ?? this.accessList,
      accessListError: clearAccessListError ? null : (accessListError ?? this.accessListError),
      operationSuccess: clearOperationStatus ? null : operationSuccess,
      operationError: clearOperationStatus ? null : operationError,
    );
  }

  @override
  List<Object?> get props => [
        interfacesLoading,
        interfaces,
        interfacesError,
        registrationsLoading,
        registrations,
        registrationsError,
        profilesLoading,
        profiles,
        profilesError,
        scanLoading,
        scanResults,
        scanError,
        accessListLoading,
        accessList,
        accessListError,
        operationSuccess,
        operationError,
      ];
}

// Keep old classes for backward compatibility but mark as deprecated
@Deprecated('Use WirelessState.copyWith instead')
class WirelessInitial extends WirelessState {
  const WirelessInitial() : super();
}

@Deprecated('Use WirelessState.copyWith(interfacesLoading: true) instead')
class WirelessInterfacesLoading extends WirelessState {
  const WirelessInterfacesLoading() : super(interfacesLoading: true);
}

@Deprecated('Use WirelessState.copyWith(interfaces: ...) instead')
class WirelessInterfacesLoaded extends WirelessState {
  const WirelessInterfacesLoaded(List<dynamic> interfaces) 
      : super(interfaces: interfaces, interfacesLoading: false);
}

@Deprecated('Use WirelessState with interface field instead')
class WirelessInterfaceLoaded extends WirelessState {
  final dynamic interface;
  const WirelessInterfaceLoaded(this.interface);
}

@Deprecated('Use WirelessState.copyWith(interfacesError: ...) instead')
class WirelessInterfacesError extends WirelessState {
  @override
  final String? interfacesError;
  String get message => interfacesError ?? '';
  const WirelessInterfacesError(String message) 
      : interfacesError = message, super(interfacesLoading: false);
}

@Deprecated('Use WirelessState.copyWith(registrationsLoading: true) instead')
class WirelessRegistrationsLoading extends WirelessState {
  const WirelessRegistrationsLoading() : super(registrationsLoading: true);
}

@Deprecated('Use WirelessState.copyWith(registrations: ...) instead')
class WirelessRegistrationsLoaded extends WirelessState {
  const WirelessRegistrationsLoaded(List<dynamic> registrations) 
      : super(registrations: registrations, registrationsLoading: false);
}

@Deprecated('Use WirelessState.copyWith(registrationsError: ...) instead')
class WirelessRegistrationsError extends WirelessState {
  @override
  final String? registrationsError;
  String get message => registrationsError ?? '';
  const WirelessRegistrationsError(String message) 
      : registrationsError = message, super(registrationsLoading: false);
}

@Deprecated('Use WirelessState.copyWith(profilesLoading: true) instead')
class SecurityProfilesLoading extends WirelessState {
  const SecurityProfilesLoading() : super(profilesLoading: true);
}

@Deprecated('Use WirelessState.copyWith(profiles: ...) instead')
class SecurityProfilesLoaded extends WirelessState {
  const SecurityProfilesLoaded(List<dynamic> profiles) 
      : super(profiles: profiles, profilesLoading: false);
}

@Deprecated('Use WirelessState with profile field instead')
class SecurityProfileLoaded extends WirelessState {
  final dynamic profile;
  const SecurityProfileLoaded(this.profile);
}

@Deprecated('Use WirelessState.copyWith(profilesError: ...) instead')
class SecurityProfilesError extends WirelessState {
  @override
  final String? profilesError;
  String get message => profilesError ?? '';
  const SecurityProfilesError(String message) 
      : profilesError = message, super(profilesLoading: false);
}

@Deprecated('Use WirelessState.copyWith(accessListLoading: true) instead')
class AccessListLoading extends WirelessState {
  const AccessListLoading() : super(accessListLoading: true);
}

@Deprecated('Use WirelessState.copyWith(accessList: ...) instead')
class AccessListLoaded extends WirelessState {
  const AccessListLoaded(List<AccessListEntry> accessList) 
      : super(accessList: accessList, accessListLoading: false);
}

@Deprecated('Use WirelessState.copyWith(accessListError: ...) instead')
class AccessListError extends WirelessState {
  @override
  final String? accessListError;
  String get message => accessListError ?? '';
  const AccessListError(String message) 
      : accessListError = message, super(accessListLoading: false);
}

@Deprecated('Use WirelessState.copyWith(operationSuccess: ...) instead')
class WirelessOperationSuccess extends WirelessState {
  @override
  final String? operationSuccess;
  String get message => operationSuccess ?? '';
  const WirelessOperationSuccess(String message) : operationSuccess = message, super();
}

@Deprecated('Use WirelessState.copyWith(operationError: ...) instead')
class WirelessOperationError extends WirelessState {
  @override
  final String? operationError;
  String get message => operationError ?? '';
  const WirelessOperationError(String message) : operationError = message, super();
}

@Deprecated('Use WirelessState.copyWith(scanLoading: true) instead')
class WirelessScanLoading extends WirelessState {
  const WirelessScanLoading() : super(scanLoading: true);
}

@Deprecated('Use WirelessState.copyWith(scanResults: ...) instead')
class WirelessScanLoaded extends WirelessState {
  const WirelessScanLoaded(List<dynamic> scanResults) 
      : super(scanResults: const [], scanLoading: false);
}

@Deprecated('Use WirelessState.copyWith(scanError: ...) instead')
class WirelessScanError extends WirelessState {
  @override
  final String? scanError;
  String get message => scanError ?? '';
  const WirelessScanError(String message) 
      : scanError = message, super(scanLoading: false);
}
