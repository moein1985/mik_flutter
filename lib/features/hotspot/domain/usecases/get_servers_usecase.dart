import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_server.dart';
import '../repositories/hotspot_repository.dart';

class GetServersUseCase {
  final HotspotRepository repository;

  GetServersUseCase(this.repository);

  Future<Either<Failure, List<HotspotServer>>> call() async {
    return await repository.getServers();
  }
}
