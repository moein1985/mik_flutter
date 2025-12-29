import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_snmp_device.dart';
import '../repositories/saved_snmp_device_repository.dart';

class UpdateDeviceUseCase {
  final SavedSnmpDeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  Future<Either<Failure, SavedSnmpDevice>> call(SavedSnmpDevice device) async {
    return repository.updateDevice(device);
  }
}
