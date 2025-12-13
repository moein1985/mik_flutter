import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/wireless_repository.dart';

class RemoveAccessListEntryUseCase {
  final WirelessRepository repository;

  RemoveAccessListEntryUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.removeAccessListEntry(id);
  }
}
