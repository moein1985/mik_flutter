import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/firewall_rule.dart';
import '../repositories/firewall_repository.dart';

class ToggleFirewallRuleUseCase {
  final FirewallRepository repository;

  ToggleFirewallRuleUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required FirewallRuleType type,
    required String id,
    required bool enable,
  }) async {
    if (enable) {
      return await repository.enableRule(type, id);
    } else {
      return await repository.disableRule(type, id);
    }
  }
}
