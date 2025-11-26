import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/system_resource.dart';
import '../repositories/dashboard_repository.dart';

class GetSystemResourcesUseCase {
  final DashboardRepository repository;

  GetSystemResourcesUseCase(this.repository);

  Future<Either<Failure, SystemResource>> call() async {
    return await repository.getSystemResources();
  }
}
