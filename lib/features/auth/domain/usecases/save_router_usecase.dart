import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_router.dart';
import '../repositories/saved_router_repository.dart';

class SaveRouterUseCase {
  final SavedRouterRepository repository;

  SaveRouterUseCase(this.repository);

  Future<Either<Failure, SavedRouter>> call({
    required String name,
    required String host,
    required int port,
    required String username,
    required String password,
    bool useSsl = false,
    bool isDefault = false,
  }) {
    final router = SavedRouter.create(
      name: name,
      host: host,
      port: port,
      username: username,
      password: password,
      useSsl: useSsl,
      isDefault: isDefault,
    );
    return repository.saveRouter(router);
  }
}
