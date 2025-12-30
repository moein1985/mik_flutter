import 'package:sqflite/sqflite.dart';
import '../models/saved_snmp_device_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/logger.dart';

/// Data source for saved SNMP devices using SQLite database
abstract class SavedSnmpDeviceLocalDataSource {
  /// Get all saved devices
  Future<List<SavedSnmpDeviceModel>> getAllDevices();

  /// Get device by ID
  Future<SavedSnmpDeviceModel?> getDeviceById(int id);

  /// Get default device
  Future<SavedSnmpDeviceModel?> getDefaultDevice();

  /// Save a new device
  Future<SavedSnmpDeviceModel> saveDevice(SavedSnmpDeviceModel device);

  /// Update an existing device
  Future<SavedSnmpDeviceModel> updateDevice(SavedSnmpDeviceModel device);

  /// Delete a device by ID
  Future<bool> deleteDevice(int id);

  /// Set a device as default
  Future<void> setDefaultDevice(int id);

  /// Update last connected time
  Future<void> updateLastConnected(int id);

  /// Check if device with same host/port/community exists
  Future<bool> deviceExists(String host, int port, String community);
}

class SavedSnmpDeviceLocalDataSourceImpl
    implements SavedSnmpDeviceLocalDataSource {
  final _log = AppLogger.tag('SavedSnmpDeviceDataSource');
  static const String _tableName = 'saved_snmp_devices';

  @override
  Future<List<SavedSnmpDeviceModel>> getAllDevices() async {
    _log.d('Getting all saved SNMP devices...');
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      orderBy: 'is_default DESC, last_connected DESC, name ASC',
    );

    final devices =
        results.map((map) => SavedSnmpDeviceModel.fromMap(map)).toList();
    _log.i('Found ${devices.length} saved SNMP devices');
    return devices;
  }

  @override
  Future<SavedSnmpDeviceModel?> getDeviceById(int id) async {
    _log.d('Getting SNMP device by ID: $id');
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      _log.d('Device not found: $id');
      return null;
    }

    return SavedSnmpDeviceModel.fromMap(results.first);
  }

  @override
  Future<SavedSnmpDeviceModel?> getDefaultDevice() async {
    _log.d('Getting default SNMP device...');
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (results.isEmpty) {
      _log.d('No default SNMP device set');
      return null;
    }

    final device = SavedSnmpDeviceModel.fromMap(results.first);
    _log.i('Default device: ${device.name}');
    return device;
  }

  @override
  Future<SavedSnmpDeviceModel> saveDevice(SavedSnmpDeviceModel device) async {
    _log.i('Saving new SNMP device: ${device.name}');
    final db = await DatabaseHelper.instance.database;

    // If this is set as default, unset other defaults first
    if (device.isDefault) {
      await _clearDefaultDevice(db);
    }

    final id = await db.insert(_tableName, device.toInsertMap());
    _log.i('Device saved with ID: $id');

    return device.copyWith(id: id) as SavedSnmpDeviceModel;
  }

  @override
  Future<SavedSnmpDeviceModel> updateDevice(
      SavedSnmpDeviceModel device) async {
    if (device.id == null) {
      throw Exception('Cannot update device without ID');
    }

    _log.i('Updating SNMP device: ${device.name} (ID: ${device.id})');
    final db = await DatabaseHelper.instance.database;

    // If this is set as default, unset other defaults first
    if (device.isDefault) {
      await _clearDefaultDevice(db);
    }

    final updatedDevice = device.copyWith(
      updatedAt: DateTime.now(),
    ) as SavedSnmpDeviceModel;

    await db.update(
      _tableName,
      updatedDevice.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );

    _log.i('Device updated successfully');
    return updatedDevice;
  }

  @override
  Future<bool> deleteDevice(int id) async {
    _log.i('Deleting SNMP device: $id');
    final db = await DatabaseHelper.instance.database;

    final count = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    final success = count > 0;
    if (success) {
      _log.i('Device deleted successfully');
    } else {
      _log.w('Device not found: $id');
    }

    return success;
  }

  @override
  Future<void> setDefaultDevice(int id) async {
    _log.i('Setting SNMP device as default: $id');
    final db = await DatabaseHelper.instance.database;

    await _clearDefaultDevice(db);

    await db.update(
      _tableName,
      {'is_default': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    _log.i('Default device set successfully');
  }

  @override
  Future<void> updateLastConnected(int id) async {
    _log.d('Updating last connected time for device: $id');
    final db = await DatabaseHelper.instance.database;

    await db.update(
      _tableName,
      {
        'last_connected': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> deviceExists(String host, int port, String community) async {
    _log.d('Checking if SNMP device exists: $host:$port');
    final db = await DatabaseHelper.instance.database;

    final results = await db.query(
      _tableName,
      where: 'host = ? AND port = ? AND community = ?',
      whereArgs: [host, port, community],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Clear default flag from all devices
  Future<void> _clearDefaultDevice(Database db) async {
    await db.update(
      _tableName,
      {'is_default': 0},
      where: 'is_default = ?',
      whereArgs: [1],
    );
  }
}
