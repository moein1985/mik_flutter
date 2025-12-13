import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/wireless_repository.dart';

class UpdateWirelessPasswordUseCase {
  final WirelessRepository repository;

  UpdateWirelessPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String securityProfileName, String newPassword) {
    return repository.updateWirelessPassword(securityProfileName, newPassword);
  }
}
