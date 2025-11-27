import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class DisconnectUserUseCase {
  final HotspotRepository repository;

  DisconnectUserUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.disconnectUser(id);
  }
}
