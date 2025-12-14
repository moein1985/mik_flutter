import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dhcp_server.dart';
import '../entities/dhcp_network.dart';
import '../entities/dhcp_lease.dart';

abstract class DhcpRepository {
  // DHCP Servers
  Future<Either<Failure, List<DhcpServer>>> getServers();
  Future<Either<Failure, bool>> addServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  });
  Future<Either<Failure, bool>> editServer({
    required String id,
    String? name,
    String? interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  });
  Future<Either<Failure, bool>> removeServer(String id);
  Future<Either<Failure, bool>> enableServer(String id);
  Future<Either<Failure, bool>> disableServer(String id);

  // DHCP Networks
  Future<Either<Failure, List<DhcpNetwork>>> getNetworks();
  Future<Either<Failure, bool>> addNetwork({
    required String address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  });
  Future<Either<Failure, bool>> editNetwork({
    required String id,
    String? address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  });
  Future<Either<Failure, bool>> removeNetwork(String id);

  // DHCP Leases
  Future<Either<Failure, List<DhcpLease>>> getLeases();
  Future<Either<Failure, bool>> addLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  });
  Future<Either<Failure, bool>> removeLease(String id);
  Future<Either<Failure, bool>> makeStatic(String id);
  Future<Either<Failure, bool>> enableLease(String id);
  Future<Either<Failure, bool>> disableLease(String id);

  // IP Pools (for dropdown)
  Future<Either<Failure, List<Map<String, String>>>> getIpPools();
  Future<Either<Failure, bool>> addIpPool({required String name, required String ranges});
  
  // Interfaces (for dropdown)
  Future<Either<Failure, List<Map<String, String>>>> getInterfaces();
}
