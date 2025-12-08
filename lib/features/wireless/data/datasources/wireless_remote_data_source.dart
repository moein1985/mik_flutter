import '../../../../core/network/routeros_client.dart';
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
  final RouterOSClient client;

  WirelessRemoteDataSourceImpl(this.client);

  @override
  Future<List<WirelessInterface>> getWirelessInterfaces() async {
    final result = await client.getWirelessInterfaces();
    return result.map((map) => WirelessInterfaceModel.fromMap(map)).toList();
  }

  @override
  Future<void> enableInterface(String interfaceName) async {
    await client.enableWirelessInterface(interfaceName);
  }

  @override
  Future<void> disableInterface(String interfaceName) async {
    await client.disableWirelessInterface(interfaceName);
  }

  @override
  Future<List<WirelessRegistration>> getWirelessRegistrations() async {
    final result = await client.getWirelessRegistrations();
    return result.map((map) => WirelessRegistrationModel.fromMap(map)).toList();
  }

  @override
  Future<List<WirelessRegistration>> getRegistrationsByInterface(String interfaceName) async {
    final result = await client.getWirelessRegistrations();
    return result
        .where((map) => map['interface'] == interfaceName)
        .map((map) => WirelessRegistrationModel.fromMap(map))
        .toList();
  }

  @override
  Future<void> disconnectClient(String interfaceName, String macAddress) async {
    await client.disconnectWirelessClient(macAddress, interfaceName);
  }

  @override
  Future<List<SecurityProfile>> getSecurityProfiles() async {
    final result = await client.getWirelessSecurityProfiles();
    return result.map((map) => SecurityProfileModel.fromMap(map)).toList();
  }

  @override
  Future<void> createSecurityProfile(SecurityProfile profile) async {
    await client.createWirelessSecurityProfile(profile.toMap());
  }

  @override
  Future<void> updateSecurityProfile(SecurityProfile profile) async {
    await client.updateWirelessSecurityProfile(profile.id, profile.toMap());
  }

  @override
  Future<void> deleteSecurityProfile(String profileId) async {
    await client.deleteWirelessSecurityProfile(profileId);
  }
}