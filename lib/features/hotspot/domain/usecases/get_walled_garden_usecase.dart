import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/walled_garden.dart';
import '../repositories/hotspot_repository.dart';

class GetWalledGardenUseCase {
  final HotspotRepository repository;

  GetWalledGardenUseCase(this.repository);

  Future<Either<Failure, List<WalledGarden>>> call() async {
    return await repository.getWalledGarden();
  }
}
