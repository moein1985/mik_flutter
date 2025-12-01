import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/saved_router_repository.dart';

class SetDefaultRouterUseCase {
  final SavedRouterRepository repository;

  SetDefaultRouterUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.setDefaultRouter(id);
  }
}
