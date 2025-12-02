import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class ToggleWalledGardenUseCase {
  final HotspotRepository repository;

  ToggleWalledGardenUseCase(this.repository);

  Future<Either<Failure, bool>> call({required String id, required bool enable}) async {
    if (enable) {
      return await repository.enableWalledGarden(id);
    } else {
      return await repository.disableWalledGarden(id);
    }
  }
}
