import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/wireless_repository.dart';

class AddVirtualWirelessInterfaceUseCase {
  final WirelessRepository repository;

  AddVirtualWirelessInterfaceUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    String? name,
    required String ssid,
    required String masterInterface,
    String? securityProfile,
    bool disabled = false,
  }) async {
    return await repository.addVirtualWirelessInterface(
      name: name,
      ssid: ssid,
      masterInterface: masterInterface,
      securityProfile: securityProfile,
      disabled: disabled,
    );
  }
}
