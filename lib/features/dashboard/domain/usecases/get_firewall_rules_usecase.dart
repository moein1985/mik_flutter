import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/firewall_rule.dart';
import '../repositories/dashboard_repository.dart';

class GetFirewallRulesUseCase {
  final DashboardRepository repository;

  GetFirewallRulesUseCase(this.repository);

  Future<Either<Failure, List<FirewallRule>>> call() async {
    return await repository.getFirewallRules();
  }
}
