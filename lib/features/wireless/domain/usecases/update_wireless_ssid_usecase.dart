import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/wireless_repository.dart';

class UpdateWirelessSsidUseCase {
  final WirelessRepository repository;

  UpdateWirelessSsidUseCase(this.repository);

  Future<Either<Failure, void>> call(String interfaceId, String newSsid) {
    return repository.updateWirelessSsid(interfaceId, newSsid);
  }
}
