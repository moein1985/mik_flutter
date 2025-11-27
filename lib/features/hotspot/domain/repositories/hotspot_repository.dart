import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_server.dart';
import '../entities/hotspot_user.dart';
import '../entities/hotspot_active_user.dart';
import '../entities/hotspot_profile.dart';

abstract class HotspotRepository {
  // Server Management
  Future<Either<Failure, List<HotspotServer>>> getServers();
  Future<Either<Failure, bool>> enableServer(String id);
  Future<Either<Failure, bool>> disableServer(String id);

  // User Management
  Future<Either<Failure, List<HotspotUser>>> getUsers();
  Future<Either<Failure, bool>> addUser({
    required String name,
    required String password,
    String? profile,
    String? server,
    String? comment,
  });
  Future<Either<Failure, bool>> removeUser(String id);
  Future<Either<Failure, bool>> enableUser(String id);
  Future<Either<Failure, bool>> disableUser(String id);

  // Active Users
  Future<Either<Failure, List<HotspotActiveUser>>> getActiveUsers();
  Future<Either<Failure, bool>> disconnectUser(String id);

  // Profile Management
  Future<Either<Failure, List<HotspotProfile>>> getProfiles();
}
