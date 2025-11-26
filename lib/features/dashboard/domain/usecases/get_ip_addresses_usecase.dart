import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ip_address.dart';
import '../repositories/dashboard_repository.dart';

class GetIpAddressesUseCase {
  final DashboardRepository repository;

  GetIpAddressesUseCase(this.repository);

  Future<Either<Failure, List<IpAddress>>> call() async {
    return await repository.getIpAddresses();
  }
}
