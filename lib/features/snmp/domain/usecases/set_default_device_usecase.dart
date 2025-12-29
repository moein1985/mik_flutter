import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/saved_snmp_device_repository.dart';

class SetDefaultDeviceUseCase {
  final SavedSnmpDeviceRepository repository;

  SetDefaultDeviceUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return repository.setDefaultDevice(id);
  }
}
