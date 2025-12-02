import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_host.dart';
import '../repositories/hotspot_repository.dart';

class GetHostsUseCase {
  final HotspotRepository repository;

  GetHostsUseCase(this.repository);

  Future<Either<Failure, List<HotspotHost>>> call() async {
    return await repository.getHosts();
  }
}
