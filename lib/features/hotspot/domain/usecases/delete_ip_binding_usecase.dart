import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class DeleteIpBindingUseCase {
  final HotspotRepository repository;

  DeleteIpBindingUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.removeIpBinding(id);
  }
}
