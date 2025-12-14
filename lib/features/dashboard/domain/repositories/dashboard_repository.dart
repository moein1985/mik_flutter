import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/system_resource.dart';
import '../entities/router_interface.dart';
import '../entities/ip_address.dart';
import '../entities/firewall_rule.dart';
import '../entities/dhcp_lease.dart';

abstract class DashboardRepository {
  Future<Either<Failure, SystemResource>> getSystemResources();
  Future<Either<Failure, List<RouterInterface>>> getInterfaces();
  Future<Either<Failure, bool>> enableInterface(String id);
  Future<Either<Failure, bool>> disableInterface(String id);
  Future<Either<Failure, List<IpAddress>>> getIpAddresses();
  Future<Either<Failure, bool>> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  });
  Future<Either<Failure, bool>> updateIpAddress({
    required String id,
    String? address,
    String? interfaceName,
    String? comment,
  });
  Future<Either<Failure, bool>> removeIpAddress(String id);
  Future<Either<Failure, bool>> toggleIpAddress(String id, bool enable);
  Future<Either<Failure, List<FirewallRule>>> getFirewallRules();
  Future<Either<Failure, bool>> enableFirewallRule(String id);
  Future<Either<Failure, bool>> disableFirewallRule(String id);
  Future<Either<Failure, List<DhcpLease>>> getDhcpLeases();
}
