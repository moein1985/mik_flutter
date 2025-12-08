import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wireless_interface.dart';
import '../repositories/wireless_repository.dart';

/// Use case for getting all wireless interfaces
class GetWirelessInterfacesUseCase {
  final WirelessRepository repository;

  GetWirelessInterfacesUseCase(this.repository);

  /// Execute get wireless interfaces operation
  Future<Either<Failure, List<WirelessInterface>>> call() async {
    return await repository.getWirelessInterfaces();
  }
}

/// Use case for enabling a wireless interface
class EnableWirelessInterfaceUseCase {
  final WirelessRepository repository;

  EnableWirelessInterfaceUseCase(this.repository);

  /// Execute enable wireless interface operation
  Future<Either<Failure, void>> call(String interfaceName) async {
    return await repository.enableInterface(interfaceName);
  }
}

/// Use case for disabling a wireless interface
class DisableWirelessInterfaceUseCase {
  final WirelessRepository repository;

  DisableWirelessInterfaceUseCase(this.repository);

  /// Execute disable wireless interface operation
  Future<Either<Failure, void>> call(String interfaceName) async {
    return await repository.disableInterface(interfaceName);
  }
}