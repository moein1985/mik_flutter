import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_user.dart';
import '../repositories/hotspot_repository.dart';

class GetUsersUseCase {
  final HotspotRepository repository;

  GetUsersUseCase(this.repository);

  Future<Either<Failure, List<HotspotUser>>> call() async {
    return await repository.getUsers();
  }
}
