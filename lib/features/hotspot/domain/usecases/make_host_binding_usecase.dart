import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class MakeHostBindingParams {
  final String id;
  final String type; // 'bypassed' or 'blocked'

  MakeHostBindingParams({
    required this.id,
    required this.type,
  });
}

class MakeHostBindingUseCase {
  final HotspotRepository repository;

  MakeHostBindingUseCase(this.repository);

  Future<Either<Failure, bool>> call(MakeHostBindingParams params) async {
    return await repository.makeHostBinding(id: params.id, type: params.type);
  }
}
