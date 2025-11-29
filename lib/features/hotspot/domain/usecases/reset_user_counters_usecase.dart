import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class ResetUserCountersUseCase {
  final HotspotRepository repository;

  ResetUserCountersUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.resetUserCounters(id);
  }
}
