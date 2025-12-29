import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/interface_info.dart';
import '../entities/device_info.dart';

abstract class SnmpRepository {
  Future<Either<Failure, List<InterfaceInfo>>> getInterfaces(
    String ip,
    String community,
    int port,
  );

  Future<Either<Failure, DeviceInfo>> getDeviceInfo(
    String ip,
    String community,
    int port,
  );

  void cancelCurrentOperation();
}
