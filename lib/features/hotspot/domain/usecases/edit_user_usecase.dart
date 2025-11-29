import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class EditUserUseCase {
  final HotspotRepository repository;

  EditUserUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String id,
    String? name,
    String? password,
    String? profile,
    String? server,
    String? comment,
    // Limits
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    return await repository.editUser(
      id: id,
      name: name,
      password: password,
      profile: profile,
      server: server,
      comment: comment,
      limitUptime: limitUptime,
      limitBytesIn: limitBytesIn,
      limitBytesOut: limitBytesOut,
      limitBytesTotal: limitBytesTotal,
    );
  }
}
