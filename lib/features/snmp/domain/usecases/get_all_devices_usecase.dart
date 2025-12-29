import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_snmp_device.dart';
import '../repositories/saved_snmp_device_repository.dart';

class GetAllDevicesUseCase {
  final SavedSnmpDeviceRepository repository;

  GetAllDevicesUseCase(this.repository);

  Future<Either<Failure, List<SavedSnmpDevice>>> call() async {
    return repository.getAllDevices();
  }
}
