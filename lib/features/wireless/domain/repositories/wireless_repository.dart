import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wireless_interface.dart';
import '../entities/wireless_registration.dart';
import '../entities/security_profile.dart';

abstract class WirelessRepository {
  /// Get all wireless interfaces
  Future<Either<Failure, List<WirelessInterface>>> getWirelessInterfaces();

  /// Get wireless registrations (connected clients) for all interfaces
  Future<Either<Failure, List<WirelessRegistration>>> getWirelessRegistrations();

  /// Get wireless registrations for a specific interface
  Future<Either<Failure, List<WirelessRegistration>>> getRegistrationsByInterface(String interfaceName);

  /// Disconnect a wireless client
  Future<Either<Failure, void>> disconnectClient(String interfaceName, String macAddress);

  /// Enable a wireless interface
  Future<Either<Failure, void>> enableInterface(String interfaceName);

  /// Disable a wireless interface
  Future<Either<Failure, void>> disableInterface(String interfaceName);

  /// Get all security profiles
  Future<Either<Failure, List<SecurityProfile>>> getSecurityProfiles();

  /// Create a new security profile
  Future<Either<Failure, void>> createSecurityProfile(SecurityProfile profile);

  /// Update an existing security profile
  Future<Either<Failure, void>> updateSecurityProfile(SecurityProfile profile);

  /// Delete a security profile
  Future<Either<Failure, void>> deleteSecurityProfile(String profileId);
}