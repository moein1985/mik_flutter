import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class AddUserUseCase {
  final HotspotRepository repository;

  AddUserUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String name,
    required String password,
    String? profile,
    String? server,
    String? comment,
  }) async {
    return await repository.addUser(
      name: name,
      password: password,
      profile: profile,
      server: server,
      comment: comment,
    );
  }
}
