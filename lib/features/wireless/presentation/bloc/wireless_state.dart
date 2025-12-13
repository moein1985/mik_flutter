import '../../domain/entities/access_list_entry.dart';

abstract class WirelessState {
  const WirelessState();
}

class WirelessInitial extends WirelessState {
  const WirelessInitial();
}

// Wireless Interfaces States
class WirelessInterfacesLoading extends WirelessState {
  const WirelessInterfacesLoading();
}

class WirelessInterfacesLoaded extends WirelessState {
  final List<dynamic> interfaces;

  const WirelessInterfacesLoaded(this.interfaces);
}

class WirelessInterfaceLoaded extends WirelessState {
  final dynamic interface;

  const WirelessInterfaceLoaded(this.interface);
}

class WirelessInterfacesError extends WirelessState {
  final String message;

  const WirelessInterfacesError(this.message);
}

// Wireless Registrations States
class WirelessRegistrationsLoading extends WirelessState {
  const WirelessRegistrationsLoading();
}

class WirelessRegistrationsLoaded extends WirelessState {
  final List<dynamic> registrations;

  const WirelessRegistrationsLoaded(this.registrations);
}

class WirelessRegistrationsError extends WirelessState {
  final String message;

  const WirelessRegistrationsError(this.message);
}

// Security Profiles States
class SecurityProfilesLoading extends WirelessState {
  const SecurityProfilesLoading();
}

class SecurityProfilesLoaded extends WirelessState {
  final List<dynamic> profiles;

  const SecurityProfilesLoaded(this.profiles);
}

class SecurityProfileLoaded extends WirelessState {
  final dynamic profile;

  const SecurityProfileLoaded(this.profile);
}

class SecurityProfilesError extends WirelessState {
  final String message;

  const SecurityProfilesError(this.message);
}

// Access List States
class AccessListLoading extends WirelessState {
  const AccessListLoading();
}

class AccessListLoaded extends WirelessState {
  final List<AccessListEntry> accessList;

  const AccessListLoaded(this.accessList);
}

class AccessListError extends WirelessState {
  final String message;

  const AccessListError(this.message);
}

// Generic Success/Error States
class WirelessOperationSuccess extends WirelessState {
  final String message;

  const WirelessOperationSuccess(this.message);
}

class WirelessOperationError extends WirelessState {
  final String message;

  const WirelessOperationError(this.message);
}

// Scanner States
class WirelessScanLoading extends WirelessState {
  const WirelessScanLoading();
}

class WirelessScanLoaded extends WirelessState {
  final List<dynamic> scanResults;

  const WirelessScanLoaded(this.scanResults);
}

class WirelessScanError extends WirelessState {
  final String message;

  const WirelessScanError(this.message);
}
