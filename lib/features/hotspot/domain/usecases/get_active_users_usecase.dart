import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_active_user.dart';
import '../repositories/hotspot_repository.dart';

class GetActiveUsersUseCase {
  final HotspotRepository repository;

  GetActiveUsersUseCase(this.repository);

  Future<Either<Failure, List<HotspotActiveUser>>> call() async {
    return await repository.getActiveUsers();
  }
}
