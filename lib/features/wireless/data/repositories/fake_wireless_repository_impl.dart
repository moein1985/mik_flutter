import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/access_list_entry.dart';
import '../../domain/entities/security_profile.dart';
import '../../domain/entities/wireless_interface.dart';
import '../../domain/entities/wireless_registration.dart';
import '../../domain/entities/wireless_scan_result.dart';
import '../../domain/repositories/wireless_repository.dart';

/// Fake implementation of WirelessRepository for development without a real router
class FakeWirelessRepositoryImpl implements WirelessRepository {
  final _random = Random();
  
  // In-memory storage
  final List<WirelessInterface> _interfaces = [
    WirelessInterface(
      id: '*1',
      name: 'wlan1',
      ssid: 'MyWiFi_5GHz',
      frequency: '5180MHz',
      band: '5GHz-A/N/AC',
      disabled: false,
      status: 'running',
      clients: 3,
      macAddress: '4A:A5:6C:12:34:56',
      mode: 'ap-bridge',
      security: 'wpa2-profile',
      txPower: 20,
      channelWidth: 20,
    ),
    WirelessInterface(
      id: '*2',
      name: 'wlan2',
      ssid: 'MyWiFi_2.4GHz',
      frequency: '2437MHz',
      band: '2GHz-B/G/N',
      disabled: false,
      status: 'running',
      clients: 5,
      macAddress: '4A:A5:6C:12:34:57',
      mode: 'ap-bridge',
      security: 'wpa2-profile',
      txPower: 17,
      channelWidth: 20,
    ),
    WirelessInterface(
      id: '*3',
      name: 'wlan-guest',
      ssid: 'GuestNetwork',
      frequency: '2462MHz',
      band: '2GHz-B/G/N',
      disabled: false,
      status: 'running',
      clients: 2,
      macAddress: '4A:A5:6C:12:34:58',
      mode: 'ap-bridge',
      security: 'guest-profile',
      txPower: 15,
      channelWidth: 20,
    ),
  ];

  final List<WirelessRegistration> _registrations = [
    WirelessRegistration(
      id: '*1',
      interface: 'wlan1',
      macAddress: '00:11:22:33:44:55',
      ipAddress: '192.168.88.10',
      signalStrength: -45,
      txRate: 300000,
      rxRate: 300000,
      uptime: '02:15:30',
      hostname: 'laptop-john',
      comment: 'John\'s Laptop',
    ),
    WirelessRegistration(
      id: '*2',
      interface: 'wlan1',
      macAddress: '00:11:22:33:44:66',
      ipAddress: '192.168.88.11',
      signalStrength: -52,
      txRate: 150000,
      rxRate: 150000,
      uptime: '01:42:18',
      hostname: 'phone-mary',
      comment: 'Mary\'s Phone',
    ),
    WirelessRegistration(
      id: '*3',
      interface: 'wlan1',
      macAddress: '00:11:22:33:44:77',
      ipAddress: '192.168.88.12',
      signalStrength: -58,
      txRate: 200000,
      rxRate: 200000,
      uptime: '00:35:22',
      hostname: 'tablet-kid',
      comment: 'Kid\'s Tablet',
    ),
    WirelessRegistration(
      id: '*4',
      interface: 'wlan2',
      macAddress: '00:AA:BB:CC:DD:EE',
      ipAddress: '192.168.88.20',
      signalStrength: -40,
      txRate: 72000,
      rxRate: 72000,
      uptime: '12:05:45',
      hostname: 'smart-tv',
      comment: 'Living Room TV',
    ),
    WirelessRegistration(
      id: '*5',
      interface: 'wlan2',
      macAddress: '00:AA:BB:CC:DD:FF',
      ipAddress: '192.168.88.21',
      signalStrength: -55,
      txRate: 54000,
      rxRate: 54000,
      uptime: '05:22:11',
      hostname: 'iot-camera',
      comment: 'Security Camera',
    ),
    WirelessRegistration(
      id: '*6',
      interface: 'wlan-guest',
      macAddress: '11:22:33:44:55:66',
      ipAddress: '192.168.89.10',
      signalStrength: -62,
      txRate: 48000,
      rxRate: 48000,
      uptime: '00:15:33',
      hostname: 'guest-phone',
      comment: '',
    ),
  ];

  final List<SecurityProfile> _securityProfiles = [
    SecurityProfile(
      id: '*1',
      name: 'wpa2-profile',
      authentication: 'wpa2-psk',
      encryption: 'aes-ccm',
      password: 'MySecurePassword123',
      mode: 'dynamic-keys',
      managementProtection: true,
      wpaPreSharedKey: 0,
      wpa2PreSharedKey: 1,
    ),
    SecurityProfile(
      id: '*2',
      name: 'guest-profile',
      authentication: 'wpa2-psk',
      encryption: 'aes-ccm',
      password: 'GuestPass456',
      mode: 'dynamic-keys',
      managementProtection: false,
      wpaPreSharedKey: 0,
      wpa2PreSharedKey: 1,
    ),
    SecurityProfile(
      id: '*3',
      name: 'wpa3-profile',
      authentication: 'wpa3-psk',
      encryption: 'aes-ccm',
      password: 'SuperSecure789!',
      mode: 'dynamic-keys',
      managementProtection: true,
      wpaPreSharedKey: 0,
      wpa2PreSharedKey: 1,
    ),
  ];

  final List<AccessListEntry> _accessList = [
    AccessListEntry(
      id: '*1',
      macAddress: '00:11:22:33:44:55',
      interface: 'wlan1',
      authentication: true,
      forwarding: true,
      comment: 'Allowed device - John\'s Laptop',
    ),
    AccessListEntry(
      id: '*2',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      interface: 'wlan1',
      authentication: false,
      forwarding: false,
      comment: 'Blocked device',
    ),
  ];

  int _idCounter = 100;

  Future<void> _simulateDelay() async {
    final delay = Duration(
      milliseconds: AppConfig.fakeMinDelay.inMilliseconds +
          _random.nextInt(
            AppConfig.fakeMaxDelay.inMilliseconds -
                AppConfig.fakeMinDelay.inMilliseconds,
          ),
    );
    await Future.delayed(delay);
  }

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  String _generateId() {
    _idCounter++;
    return '*$_idCounter';
  }

  @override
  Future<Either<Failure, List<WirelessInterface>>> getWirelessInterfaces() async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to get wireless interfaces'));
    }

    return Right(List.from(_interfaces));
  }

  @override
  Future<Either<Failure, List<WirelessRegistration>>> getWirelessRegistrations() async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to get wireless registrations'));
    }

    return Right(List.from(_registrations));
  }

  @override
  Future<Either<Failure, List<WirelessRegistration>>> getRegistrationsByInterface(
    String interfaceName,
  ) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to get registrations for $interfaceName'));
    }

    final filtered = _registrations
        .where((reg) => reg.interface == interfaceName)
        .toList();
    return Right(filtered);
  }

  @override
  Future<Either<Failure, void>> disconnectClient(
    String interfaceName,
    String macAddress,
  ) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disconnect client'));
    }

    _registrations.removeWhere(
      (reg) => reg.interface == interfaceName && reg.macAddress == macAddress,
    );

    // Update interface client count
    final interfaceIndex = _interfaces.indexWhere((i) => i.name == interfaceName);
    if (interfaceIndex != -1) {
      final currentInterface = _interfaces[interfaceIndex];
      final newClientCount = _registrations
          .where((reg) => reg.interface == interfaceName)
          .length;
      
      _interfaces[interfaceIndex] = WirelessInterface(
        id: currentInterface.id,
        name: currentInterface.name,
        ssid: currentInterface.ssid,
        frequency: currentInterface.frequency,
        band: currentInterface.band,
        disabled: currentInterface.disabled,
        status: currentInterface.status,
        clients: newClientCount,
        macAddress: currentInterface.macAddress,
        mode: currentInterface.mode,
        security: currentInterface.security,
        txPower: currentInterface.txPower,
        channelWidth: currentInterface.channelWidth,
      );
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> enableInterface(String interfaceName) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to enable interface $interfaceName'));
    }

    final index = _interfaces.indexWhere((i) => i.name == interfaceName);
    if (index == -1) {
      return Left(NotFoundFailure('Interface $interfaceName not found'));
    }

    final current = _interfaces[index];
    _interfaces[index] = WirelessInterface(
      id: current.id,
      name: current.name,
      ssid: current.ssid,
      frequency: current.frequency,
      band: current.band,
      disabled: false,
      status: 'running',
      clients: current.clients,
      macAddress: current.macAddress,
      mode: current.mode,
      security: current.security,
      txPower: current.txPower,
      channelWidth: current.channelWidth,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> disableInterface(String interfaceName) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to disable interface $interfaceName'));
    }

    final index = _interfaces.indexWhere((i) => i.name == interfaceName);
    if (index == -1) {
      return Left(NotFoundFailure('Interface $interfaceName not found'));
    }

    final current = _interfaces[index];
    _interfaces[index] = WirelessInterface(
      id: current.id,
      name: current.name,
      ssid: current.ssid,
      frequency: current.frequency,
      band: current.band,
      disabled: true,
      status: 'stopped',
      clients: 0,
      macAddress: current.macAddress,
      mode: current.mode,
      security: current.security,
      txPower: current.txPower,
      channelWidth: current.channelWidth,
    );

    // Remove all registrations for this interface
    _registrations.removeWhere((reg) => reg.interface == interfaceName);

    return const Right(null);
  }

  @override
  Future<Either<Failure, List<SecurityProfile>>> getSecurityProfiles() async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to get security profiles'));
    }

    return Right(List.from(_securityProfiles));
  }

  @override
  Future<Either<Failure, void>> createSecurityProfile(SecurityProfile profile) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to create security profile'));
    }

    // Check if profile name already exists
    if (_securityProfiles.any((p) => p.name == profile.name)) {
      return Left(ValidationFailure('Security profile ${profile.name} already exists'));
    }

    final newProfile = SecurityProfile(
      id: _generateId(),
      name: profile.name,
      authentication: profile.authentication,
      encryption: profile.encryption,
      password: profile.password,
      mode: profile.mode,
      managementProtection: profile.managementProtection,
      wpaPreSharedKey: profile.wpaPreSharedKey,
      wpa2PreSharedKey: profile.wpa2PreSharedKey,
    );

    _securityProfiles.add(newProfile);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateSecurityProfile(SecurityProfile profile) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update security profile'));
    }

    final index = _securityProfiles.indexWhere((p) => p.id == profile.id);
    if (index == -1) {
      return Left(NotFoundFailure('Security profile not found'));
    }

    _securityProfiles[index] = profile;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteSecurityProfile(String profileId) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to delete security profile'));
    }

    final index = _securityProfiles.indexWhere((p) => p.id == profileId);
    if (index == -1) {
      return Left(NotFoundFailure('Security profile not found'));
    }

    // Check if profile is in use
    final profileName = _securityProfiles[index].name;
    if (_interfaces.any((i) => i.security == profileName)) {
      return Left(ValidationFailure('Cannot delete security profile $profileName - it is in use'));
    }

    _securityProfiles.removeAt(index);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<WirelessScanResult>>> scanWirelessNetworks({
    required String interfaceId,
    int? duration,
  }) async {
    // Simulate scan duration
    final scanDuration = duration ?? 5;
    await Future.delayed(Duration(seconds: scanDuration));

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to scan wireless networks'));
    }

    // Generate fake scan results
    final scanResults = <WirelessScanResult>[
      WirelessScanResult(
        ssid: 'NeighborWiFi',
        macAddress: 'AA:BB:CC:11:22:33',
        channel: '6',
        signalStrength: -65,
        band: '2GHz-B/G/N',
        security: 'wpa2-psk',
      ),
      WirelessScanResult(
        ssid: 'CoffeeShop_Public',
        macAddress: 'BB:CC:DD:22:33:44',
        channel: '11',
        signalStrength: -72,
        band: '2GHz-B/G/N',
        security: 'open',
      ),
      WirelessScanResult(
        ssid: 'Office_5G',
        macAddress: 'CC:DD:EE:33:44:55',
        channel: '36',
        signalStrength: -58,
        band: '5GHz-A/N/AC',
        security: 'wpa2-psk',
        routerosVersion: '7.10',
      ),
      WirelessScanResult(
        ssid: 'HomeNetwork',
        macAddress: 'DD:EE:FF:44:55:66',
        channel: '1',
        signalStrength: -70,
        band: '2GHz-B/G/N',
        security: 'wpa2-psk',
      ),
    ];

    return Right(scanResults);
  }

  @override
  Future<Either<Failure, List<AccessListEntry>>> getAccessList() async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to get access list'));
    }

    return Right(List.from(_accessList));
  }

  @override
  Future<Either<Failure, void>> addAccessListEntry(AccessListEntry entry) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add access list entry'));
    }

    // Check if MAC address already exists
    if (_accessList.any((e) => e.macAddress == entry.macAddress)) {
      return Left(ValidationFailure('MAC address ${entry.macAddress} already in access list'));
    }

    final newEntry = AccessListEntry(
      id: _generateId(),
      macAddress: entry.macAddress,
      interface: entry.interface,
      authentication: entry.authentication,
      forwarding: entry.forwarding,
      apTxLimit: entry.apTxLimit,
      clientTxLimit: entry.clientTxLimit,
      signalRange: entry.signalRange,
      time: entry.time,
      comment: entry.comment,
    );

    _accessList.add(newEntry);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeAccessListEntry(String id) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove access list entry'));
    }

    final index = _accessList.indexWhere((e) => e.id == id);
    if (index == -1) {
      return Left(NotFoundFailure('Access list entry not found'));
    }

    _accessList.removeAt(index);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateAccessListEntry(AccessListEntry entry) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update access list entry'));
    }

    final index = _accessList.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      return Left(NotFoundFailure('Access list entry not found'));
    }

    _accessList[index] = entry;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateWirelessSsid(
    String interfaceId,
    String newSsid,
  ) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update SSID'));
    }

    final index = _interfaces.indexWhere((i) => i.id == interfaceId);
    if (index == -1) {
      return Left(NotFoundFailure('Interface not found'));
    }

    final current = _interfaces[index];
    _interfaces[index] = WirelessInterface(
      id: current.id,
      name: current.name,
      ssid: newSsid,
      frequency: current.frequency,
      band: current.band,
      disabled: current.disabled,
      status: current.status,
      clients: current.clients,
      macAddress: current.macAddress,
      mode: current.mode,
      security: current.security,
      txPower: current.txPower,
      channelWidth: current.channelWidth,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> getWirelessPassword(
    String securityProfileName,
  ) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to get wireless password'));
    }

    final profile = _securityProfiles.firstWhere(
      (p) => p.name == securityProfileName,
      orElse: () => throw Exception('Profile not found'),
    );

    return Right(profile.password);
  }

  @override
  Future<Either<Failure, void>> updateWirelessPassword(
    String securityProfileName,
    String newPassword,
  ) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update wireless password'));
    }

    final index = _securityProfiles.indexWhere((p) => p.name == securityProfileName);
    if (index == -1) {
      return Left(NotFoundFailure('Security profile not found'));
    }

    final current = _securityProfiles[index];
    _securityProfiles[index] = SecurityProfile(
      id: current.id,
      name: current.name,
      authentication: current.authentication,
      encryption: current.encryption,
      password: newPassword,
      mode: current.mode,
      managementProtection: current.managementProtection,
      wpaPreSharedKey: current.wpaPreSharedKey,
      wpa2PreSharedKey: current.wpa2PreSharedKey,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> addVirtualWirelessInterface({
    String? name,
    required String ssid,
    required String masterInterface,
    String? securityProfile,
    bool disabled = false,
  }) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add virtual wireless interface'));
    }

    // Check if master interface exists
    if (!_interfaces.any((i) => i.name == masterInterface)) {
      return Left(NotFoundFailure('Master interface $masterInterface not found'));
    }

    // Generate interface name if not provided
    final interfaceName = name ?? 'wlan-virtual-${_idCounter + 1}';

    // Check if interface name already exists
    if (_interfaces.any((i) => i.name == interfaceName)) {
      return Left(ValidationFailure('Interface name $interfaceName already exists'));
    }

    // Get master interface to copy properties
    final master = _interfaces.firstWhere((i) => i.name == masterInterface);

    final newInterface = WirelessInterface(
      id: _generateId(),
      name: interfaceName,
      ssid: ssid,
      frequency: master.frequency,
      band: master.band,
      disabled: disabled,
      status: disabled ? 'stopped' : 'running',
      clients: 0,
      macAddress: _generateMacAddress(),
      mode: 'ap-bridge',
      security: securityProfile ?? master.security,
      txPower: master.txPower,
      channelWidth: master.channelWidth,
    );

    _interfaces.add(newInterface);
    return const Right(true);
  }

  @override
  Future<Either<Failure, void>> removeWirelessInterface(String id) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove wireless interface'));
    }

    final index = _interfaces.indexWhere((i) => i.id == id);
    if (index == -1) {
      return Left(NotFoundFailure('Interface not found'));
    }

    final interfaceName = _interfaces[index].name;
    
    // Remove all registrations for this interface
    _registrations.removeWhere((reg) => reg.interface == interfaceName);
    
    // Remove the interface
    _interfaces.removeAt(index);

    return const Right(null);
  }

  String _generateMacAddress() {
    final parts = List.generate(6, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    return parts.join(':').toUpperCase();
  }
}
