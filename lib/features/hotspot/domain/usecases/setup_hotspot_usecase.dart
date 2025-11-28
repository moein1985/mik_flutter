import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class SetupHotspotUseCase {
  final HotspotRepository repository;

  SetupHotspotUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String interface,
    String? addressPool,
    String? dnsName,
  }) async {
    return await repository.setupHotspot(
      interface: interface,
      addressPool: addressPool,
      dnsName: dnsName,
    );
  }
}
