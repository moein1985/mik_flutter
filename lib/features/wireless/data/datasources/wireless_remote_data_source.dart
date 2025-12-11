import '../../../../core/network/routeros_client_v2.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/wireless_interface.dart';
import '../../domain/entities/wireless_registration.dart';
import '../../domain/entities/security_profile.dart';
import '../models/wireless_interface_model.dart';
import '../models/wireless_registration_model.dart';
import '../models/security_profile_model.dart';

abstract class WirelessRemoteDataSource {
  Future<List<WirelessInterface>> getWirelessInterfaces();
  Future<void> enableInterface(String interfaceName);
  Future<void> disableInterface(String interfaceName);

  Future<List<WirelessRegistration>> getWirelessRegistrations();
  Future<List<WirelessRegistration>> getRegistrationsByInterface(String interfaceName);
  Future<void> disconnectClient(String interfaceName, String macAddress);

  Future<List<SecurityProfile>> getSecurityProfiles();
  Future<void> createSecurityProfile(SecurityProfile profile);
  Future<void> updateSecurityProfile(SecurityProfile profile);
  Future<void> deleteSecurityProfile(String profileId);
}

class WirelessRemoteDataSourceImpl implements WirelessRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  WirelessRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClientV2 get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<List<WirelessInterface>> getWirelessInterfaces() async {
    try {
      final result = await client.getWirelessInterfaces();
      return result.map((map) => WirelessInterfaceModel.fromMap(map)).toList();
    } catch (e) {
      throw ServerException('Failed to get wireless interfaces: $e');
    }
  }

  @override
  Future<void> enableInterface(String interfaceName) async {
    try {
      await client.enableWirelessInterface(interfaceName);
    } catch (e) {
      throw ServerException('Failed to enable wireless interface: $e');
    }
  }

  @override
  Future<void> disableInterface(String interfaceName) async {
    try {
      await client.disableWirelessInterface(interfaceName);
    } catch (e) {
      throw ServerException('Failed to disable wireless interface: $e');
    }
  }

  @override
  Future<List<WirelessRegistration>> getWirelessRegistrations() async {
    try {
      final result = await client.getWirelessRegistrations();
      return result.map((map) => WirelessRegistrationModel.fromMap(map)).toList();
    } catch (e) {
      throw ServerException('Failed to get wireless registrations: $e');
    }
  }

  @override
  Future<List<WirelessRegistration>> getRegistrationsByInterface(String interfaceName) async {
    try {
      final result = await client.getWirelessRegistrations(interface: interfaceName);
      return result.map((map) => WirelessRegistrationModel.fromMap(map)).toList();
    } catch (e) {
      throw ServerException('Failed to get wireless registrations: $e');
    }
  }

  @override
  Future<void> disconnectClient(String interfaceName, String macAddress) async {
    try {
      await client.disconnectWirelessClient(interface: interfaceName, macAddress: macAddress);
    } catch (e) {
      throw ServerException('Failed to disconnect wireless client: $e');
    }
  }

  @override
  Future<List<SecurityProfile>> getSecurityProfiles() async {
    try {
      final result = await client.getWirelessSecurityProfiles();
      return result.map((map) => SecurityProfileModel.fromMap(map)).toList();
    } catch (e) {
      throw ServerException('Failed to get security profiles: $e');
    }
  }

  @override
  Future<void> createSecurityProfile(SecurityProfile profile) async {
    try {
      await client.createWirelessSecurityProfile(
        name: profile.name,
        authenticationTypes: profile.authentication,
        unicastCiphers: profile.encryption,
        groupCiphers: profile.encryption,
        wpaPreSharedKey: profile.password,
        wpa2PreSharedKey: profile.password,
      );
    } catch (e) {
      throw ServerException('Failed to create security profile: $e');
    }
  }

  @override
  Future<void> updateSecurityProfile(SecurityProfile profile) async {
    try {
      await client.updateWirelessSecurityProfile(
        id: profile.id,
        name: profile.name,
        authenticationTypes: profile.authentication,
        unicastCiphers: profile.encryption,
        groupCiphers: profile.encryption,
        wpaPreSharedKey: profile.password,
        wpa2PreSharedKey: profile.password,
      );
    } catch (e) {
      throw ServerException('Failed to update security profile: $e');
    }
  }

  @override
  Future<void> deleteSecurityProfile(String profileId) async {
    try {
      await client.deleteWirelessSecurityProfile(profileId);
    } catch (e) {
      throw ServerException('Failed to delete security profile: $e');
    }
  }
}