import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_profile.dart';
import '../repositories/hotspot_repository.dart';

class GetProfilesUseCase {
  final HotspotRepository repository;

  GetProfilesUseCase(this.repository);

  Future<Either<Failure, List<HotspotProfile>>> call() async {
    return await repository.getProfiles();
  }
}
