import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_ip_binding.dart';
import '../repositories/hotspot_repository.dart';

class GetIpBindingsUseCase {
  final HotspotRepository repository;

  GetIpBindingsUseCase(this.repository);

  Future<Either<Failure, List<HotspotIpBinding>>> call() async {
    return await repository.getIpBindings();
  }
}
