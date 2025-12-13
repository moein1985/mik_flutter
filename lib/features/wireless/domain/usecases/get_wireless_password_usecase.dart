import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/wireless_repository.dart';

class GetWirelessPasswordUseCase {
  final WirelessRepository repository;

  GetWirelessPasswordUseCase(this.repository);

  Future<Either<Failure, String>> call(String securityProfileName) {
    return repository.getWirelessPassword(securityProfileName);
  }
}
