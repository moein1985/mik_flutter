import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/interface_info.dart';
import '../repositories/snmp_repository.dart';

class GetInterfaceStatusUseCase {
  final SnmpRepository repository;
  
  GetInterfaceStatusUseCase(this.repository);
  
  Future<Either<Failure, List<InterfaceInfo>>> call(String ip, String community, int port) async {
    return repository.getInterfaces(ip, community, port);
  }
  
  void cancelOperation() {
    repository.cancelCurrentOperation();
  }
}
