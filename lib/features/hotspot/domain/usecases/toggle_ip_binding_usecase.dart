import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class ToggleIpBindingUseCase {
  final HotspotRepository repository;

  ToggleIpBindingUseCase(this.repository);

  Future<Either<Failure, bool>> call({required String id, required bool enable}) async {
    if (enable) {
      return await repository.enableIpBinding(id);
    } else {
      return await repository.disableIpBinding(id);
    }
  }
}
