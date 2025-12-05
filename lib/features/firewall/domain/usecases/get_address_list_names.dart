import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/firewall_repository.dart';

class GetAddressListNamesUseCase {
  final FirewallRepository repository;

  GetAddressListNamesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getAddressListNames();
  }
}
