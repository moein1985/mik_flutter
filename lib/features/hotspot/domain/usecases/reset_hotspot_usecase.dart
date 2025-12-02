import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

/// Parameters for reset hotspot operation
class ResetHotspotParams {
  final bool deleteUsers;
  final bool deleteProfiles;
  final bool deleteIpBindings;
  final bool deleteWalledGarden;
  final bool deleteServers;
  final bool deleteServerProfiles;
  final bool deleteIpPools;

  const ResetHotspotParams({
    this.deleteUsers = true,
    this.deleteProfiles = true,
    this.deleteIpBindings = true,
    this.deleteWalledGarden = true,
    this.deleteServers = true,
    this.deleteServerProfiles = true,
    this.deleteIpPools = false, // Optional - may affect other services
  });
}

class ResetHotspotUseCase {
  final HotspotRepository repository;

  ResetHotspotUseCase(this.repository);

  Future<Either<Failure, bool>> call(ResetHotspotParams params) async {
    return await repository.resetHotspot(
      deleteUsers: params.deleteUsers,
      deleteProfiles: params.deleteProfiles,
      deleteIpBindings: params.deleteIpBindings,
      deleteWalledGarden: params.deleteWalledGarden,
      deleteServers: params.deleteServers,
      deleteServerProfiles: params.deleteServerProfiles,
      deleteIpPools: params.deleteIpPools,
    );
  }
}
