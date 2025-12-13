import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/access_list_entry.dart';
import '../repositories/wireless_repository.dart';

class UpdateAccessListEntryUseCase {
  final WirelessRepository repository;

  UpdateAccessListEntryUseCase(this.repository);

  Future<Either<Failure, void>> call(AccessListEntry entry) async {
    return await repository.updateAccessListEntry(entry);
  }
}
