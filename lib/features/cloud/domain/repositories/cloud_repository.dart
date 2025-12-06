import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cloud_status.dart';

abstract class CloudRepository {
  /// Get current cloud status
  Future<Either<Failure, CloudStatus>> getCloudStatus();

  /// Enable DDNS
  Future<Either<Failure, bool>> enableDdns();

  /// Disable DDNS
  Future<Either<Failure, bool>> disableDdns();

  /// Force update DDNS
  Future<Either<Failure, bool>> forceUpdate();

  /// Set DDNS update interval
  Future<Either<Failure, bool>> setUpdateInterval(String interval);

  /// Enable/disable update time from cloud
  Future<Either<Failure, bool>> setUpdateTime(bool enabled);
}
