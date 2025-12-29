import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/saved_snmp_device_repository.dart';

class DeleteDeviceUseCase {
  final SavedSnmpDeviceRepository repository;

  DeleteDeviceUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) async {
    return repository.deleteDevice(id);
  }
}
