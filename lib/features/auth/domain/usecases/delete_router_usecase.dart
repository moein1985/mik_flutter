import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/saved_router_repository.dart';

class DeleteRouterUseCase {
  final SavedRouterRepository repository;

  DeleteRouterUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.deleteRouter(id);
  }
}
