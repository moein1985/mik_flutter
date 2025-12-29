import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_snmp_device.dart';

abstract class SavedSnmpDeviceRepository {
  /// Get all saved SNMP devices
  Future<Either<Failure, List<SavedSnmpDevice>>> getAllDevices();

  /// Get device by ID
  Future<Either<Failure, SavedSnmpDevice>> getDeviceById(int id);

  /// Get default device
  Future<Either<Failure, SavedSnmpDevice?>> getDefaultDevice();

  /// Save a new device
  Future<Either<Failure, SavedSnmpDevice>> saveDevice(SavedSnmpDevice device);

  /// Update an existing device
  Future<Either<Failure, SavedSnmpDevice>> updateDevice(SavedSnmpDevice device);

  /// Delete a device by ID
  Future<Either<Failure, bool>> deleteDevice(int id);

  /// Set a device as default
  Future<Either<Failure, void>> setDefaultDevice(int id);

  /// Update last connected time
  Future<Either<Failure, void>> updateLastConnected(int id);

  /// Check if device with same host/port/community exists
  Future<Either<Failure, bool>> deviceExists(
    String host,
    int port,
    String community,
  );
}
