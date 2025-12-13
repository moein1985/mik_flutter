import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/access_list_entry.dart';
import '../repositories/wireless_repository.dart';

class GetAccessListUseCase {
  final WirelessRepository repository;

  GetAccessListUseCase(this.repository);

  Future<Either<Failure, List<AccessListEntry>>> call() async {
    return await repository.getAccessList();
  }
}
