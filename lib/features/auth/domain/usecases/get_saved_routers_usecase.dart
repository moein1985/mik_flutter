import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_router.dart';
import '../repositories/saved_router_repository.dart';

class GetSavedRoutersUseCase {
  final SavedRouterRepository repository;

  GetSavedRoutersUseCase(this.repository);

  Future<Either<Failure, List<SavedRouter>>> call() {
    return repository.getAllRouters();
  }
}
