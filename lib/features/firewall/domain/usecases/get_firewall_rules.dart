import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/firewall_rule.dart';
import '../repositories/firewall_repository.dart';

class GetFirewallRulesUseCase {
  final FirewallRepository repository;

  GetFirewallRulesUseCase(this.repository);

  Future<Either<Failure, List<FirewallRule>>> call(FirewallRuleType type) async {
    return await repository.getRules(type);
  }
}
