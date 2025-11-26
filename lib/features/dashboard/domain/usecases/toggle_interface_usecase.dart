import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dashboard_repository.dart';

class ToggleInterfaceUseCase {
  final DashboardRepository repository;

  ToggleInterfaceUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id, bool enable) async {
    if (enable) {
      return await repository.enableInterface(id);
    } else {
      return await repository.disableInterface(id);
    }
  }
}
