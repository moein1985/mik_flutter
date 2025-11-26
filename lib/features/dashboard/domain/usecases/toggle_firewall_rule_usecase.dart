import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dashboard_repository.dart';

class ToggleFirewallRuleUseCase {
  final DashboardRepository repository;

  ToggleFirewallRuleUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id, bool enable) async {
    if (enable) {
      return await repository.enableFirewallRule(id);
    } else {
      return await repository.disableFirewallRule(id);
    }
  }
}
