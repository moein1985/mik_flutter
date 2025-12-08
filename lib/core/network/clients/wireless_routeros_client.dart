import 'package:dartz/dartz.dart';
import '../../../features/wireless/data/models/wireless_interface_model.dart';
import '../../../features/wireless/data/models/wireless_registration_model.dart';
import '../../../features/wireless/data/models/security_profile_model.dart';
import '../../errors/failures.dart';
import 'base_routeros_client.dart';

class WirelessRouterOSClient extends BaseRouterOSClient {
  WirelessRouterOSClient(super.client);

  /// Get all wireless interfaces
  Future<Either<Failure, List<WirelessInterfaceModel>>> getWirelessInterfaces() async {
    final result = await executeCommand(['/interface/wireless/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.map((item) => WirelessInterfaceModel.fromMap(item)).toList()),
    );
  }

  /// Enable wireless interface
  Future<Either<Failure, void>> enableInterface(String interfaceName) async {
    return executeVoidCommand([
      '/interface/wireless/enable',
      '=numbers=$interfaceName',
    ]);
  }

  /// Disable wireless interface
  Future<Either<Failure, void>> disableInterface(String interfaceName) async {
    return executeVoidCommand([
      '/interface/wireless/disable',
      '=numbers=$interfaceName',
    ]);
  }

  /// Get wireless registrations (connected clients)
  Future<Either<Failure, List<WirelessRegistrationModel>>> getWirelessRegistrations() async {
    final result = await executeCommand(['/interface/wireless/registration-table/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.map((item) => WirelessRegistrationModel.fromMap(item)).toList()),
    );
  }

  /// Get wireless registrations for specific interface
  Future<Either<Failure, List<WirelessRegistrationModel>>> getRegistrationsByInterface(String interfaceName) async {
    final result = await executeCommand([
      '/interface/wireless/registration-table/print',
      '?interface=$interfaceName',
    ]);
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.map((item) => WirelessRegistrationModel.fromMap(item)).toList()),
    );
  }

  /// Disconnect wireless client
  Future<Either<Failure, void>> disconnectClient(String interfaceName, String macAddress) async {
    return executeVoidCommand([
      '/interface/wireless/registration-table/remove',
      '?interface=$interfaceName',
      '?mac-address=$macAddress',
    ]);
  }

  /// Get security profiles
  Future<Either<Failure, List<SecurityProfileModel>>> getSecurityProfiles() async {
    final result = await executeCommand(['/interface/wireless/security-profiles/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.map((item) => SecurityProfileModel.fromMap(item)).toList()),
    );
  }

  /// Create security profile
  Future<Either<Failure, void>> createSecurityProfile(SecurityProfileModel profile) async {
    final command = ['/interface/wireless/security-profiles/add'];
    if (profile.name.isNotEmpty) command.add('=name=${profile.name}');
    if (profile.mode.isNotEmpty) command.add('=mode=${profile.mode}');
    if (profile.authentication.isNotEmpty) {
      command.add('=authentication-types=${profile.authentication}');
    }
    if (profile.encryption.isNotEmpty) command.add('=encryption=${profile.encryption}');
    if (profile.password.isNotEmpty) {
      command.add('=wpa-pre-shared-key=${profile.password}');
      command.add('=wpa2-pre-shared-key=${profile.password}');
    }

    return executeVoidCommand(command);
  }
}