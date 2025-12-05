import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/firewall_rule.dart';
import '../repositories/firewall_repository.dart';

class GetAddressListByNameUseCase {
  final FirewallRepository repository;

  GetAddressListByNameUseCase(this.repository);

  Future<Either<Failure, List<FirewallRule>>> call(String listName) async {
    return await repository.getAddressListByName(listName);
  }
}
