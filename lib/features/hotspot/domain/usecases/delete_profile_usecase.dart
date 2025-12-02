import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class DeleteProfileUseCase {
  final HotspotRepository repository;

  DeleteProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.removeProfile(id);
  }
}
