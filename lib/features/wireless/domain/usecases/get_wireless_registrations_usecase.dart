import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wireless_registration.dart';
import '../repositories/wireless_repository.dart';

/// Use case for getting all wireless registrations (connected clients)
class GetWirelessRegistrationsUseCase {
  final WirelessRepository repository;

  GetWirelessRegistrationsUseCase(this.repository);

  /// Execute get wireless registrations operation
  Future<Either<Failure, List<WirelessRegistration>>> call() async {
    return await repository.getWirelessRegistrations();
  }
}

/// Use case for getting wireless registrations by interface
class GetRegistrationsByInterfaceUseCase {
  final WirelessRepository repository;

  GetRegistrationsByInterfaceUseCase(this.repository);

  /// Execute get registrations by interface operation
  Future<Either<Failure, List<WirelessRegistration>>> call(String interfaceName) async {
    return await repository.getRegistrationsByInterface(interfaceName);
  }
}

/// Use case for disconnecting a wireless client
class DisconnectClientUseCase {
  final WirelessRepository repository;

  DisconnectClientUseCase(this.repository);

  /// Execute disconnect client operation
  Future<Either<Failure, void>> call(String interfaceName, String macAddress) async {
    return await repository.disconnectClient(interfaceName, macAddress);
  }
}