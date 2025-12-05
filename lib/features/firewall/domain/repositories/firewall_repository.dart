import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/firewall_rule.dart';

abstract class FirewallRepository {
  /// Get all rules of a specific type
  Future<Either<Failure, List<FirewallRule>>> getRules(FirewallRuleType type);
  
  /// Enable a rule
  Future<Either<Failure, bool>> enableRule(FirewallRuleType type, String id);
  
  /// Disable a rule
  Future<Either<Failure, bool>> disableRule(FirewallRuleType type, String id);
  
  /// Get unique list names (for address-list filtering)
  Future<Either<Failure, List<String>>> getAddressListNames();
  
  /// Get address list entries filtered by list name
  Future<Either<Failure, List<FirewallRule>>> getAddressListByName(String listName);
}
