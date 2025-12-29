import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_info.dart';
import '../repositories/snmp_repository.dart';

class GetDeviceInfoUseCase {
  final SnmpRepository repository;
  
  GetDeviceInfoUseCase(this.repository);
  
  Future<Either<Failure, DeviceInfo>> call(String ip, String community, int port) async {
    return repository.getDeviceInfo(ip, community, port);
  }
  
  void cancelOperation() {
    repository.cancelCurrentOperation();
  }
}
