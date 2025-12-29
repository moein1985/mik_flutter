import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_snmp_device.dart';
import '../repositories/saved_snmp_device_repository.dart';

class GetDefaultDeviceUseCase {
  final SavedSnmpDeviceRepository repository;

  GetDefaultDeviceUseCase(this.repository);

  Future<Either<Failure, SavedSnmpDevice?>> call() async {
    return repository.getDefaultDevice();
  }
}
