import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class ToggleUserUseCase {
  final HotspotRepository repository;

  ToggleUserUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String id,
    required bool enable,
  }) async {
    if (enable) {
      return await repository.enableUser(id);
    } else {
      return await repository.disableUser(id);
    }
  }
}
