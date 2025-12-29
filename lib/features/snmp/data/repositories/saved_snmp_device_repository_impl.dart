import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/saved_snmp_device.dart';
import '../../domain/repositories/saved_snmp_device_repository.dart';
import '../datasources/saved_snmp_device_local_data_source.dart';
import '../models/saved_snmp_device_model.dart';

class SavedSnmpDeviceRepositoryImpl implements SavedSnmpDeviceRepository {
  final SavedSnmpDeviceLocalDataSource localDataSource;

  SavedSnmpDeviceRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<SavedSnmpDevice>>> getAllDevices() async {
    try {
      final devices = await localDataSource.getAllDevices();
      return Right(devices);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get devices: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavedSnmpDevice>> getDeviceById(int id) async {
    try {
      final device = await localDataSource.getDeviceById(id);
      if (device == null) {
        return Left(DatabaseFailure('Device not found'));
      }
      return Right(device);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavedSnmpDevice?>> getDefaultDevice() async {
    try {
      final device = await localDataSource.getDefaultDevice();
      return Right(device);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get default device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavedSnmpDevice>> saveDevice(
      SavedSnmpDevice device) async {
    try {
      // Check if device already exists
      final exists = await localDataSource.deviceExists(
        device.host,
        device.port,
        device.community,
      );
      
      if (exists) {
        return Left(DatabaseFailure('Device already exists with the same host, port, and community'));
      }

      final model = SavedSnmpDeviceModel.fromEntity(device);
      final savedDevice = await localDataSource.saveDevice(model);
      return Right(savedDevice);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavedSnmpDevice>> updateDevice(
      SavedSnmpDevice device) async {
    try {
      if (device.id == null) {
        return Left(DatabaseFailure('Cannot update device without ID'));
      }

      final model = SavedSnmpDeviceModel.fromEntity(device);
      final updatedDevice = await localDataSource.updateDevice(model);
      return Right(updatedDevice);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDevice(int id) async {
    try {
      final success = await localDataSource.deleteDevice(id);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultDevice(int id) async {
    try {
      await localDataSource.setDefaultDevice(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to set default device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastConnected(int id) async {
    try {
      await localDataSource.updateLastConnected(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update last connected: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deviceExists(
    String host,
    int port,
    String community,
  ) async {
    try {
      final exists = await localDataSource.deviceExists(host, port, community);
      return Right(exists);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check device existence: ${e.toString()}'));
    }
  }
}
