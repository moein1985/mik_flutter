import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/access_list_entry.dart';
import '../repositories/wireless_repository.dart';

class AddAccessListEntryUseCase {
  final WirelessRepository repository;

  AddAccessListEntryUseCase(this.repository);

  Future<Either<Failure, void>> call(AccessListEntry entry) async {
    return await repository.addAccessListEntry(entry);
  }
}
