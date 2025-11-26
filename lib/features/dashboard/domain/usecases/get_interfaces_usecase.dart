import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/router_interface.dart';
import '../repositories/dashboard_repository.dart';

class GetInterfacesUseCase {
  final DashboardRepository repository;

  GetInterfacesUseCase(this.repository);

  Future<Either<Failure, List<RouterInterface>>> call() async {
    return await repository.getInterfaces();
  }
}
