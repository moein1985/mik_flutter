import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class DeleteUserUseCase {
  final HotspotRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.removeUser(id);
  }
}
