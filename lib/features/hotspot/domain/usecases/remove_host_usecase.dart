import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class RemoveHostUseCase {
  final HotspotRepository repository;

  RemoveHostUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.removeHost(id);
  }
}
