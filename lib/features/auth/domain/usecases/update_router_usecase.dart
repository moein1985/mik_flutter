import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_router.dart';
import '../repositories/saved_router_repository.dart';

class UpdateRouterUseCase {
  final SavedRouterRepository repository;

  UpdateRouterUseCase(this.repository);

  Future<Either<Failure, SavedRouter>> call(SavedRouter router) {
    return repository.updateRouter(router);
  }
}
