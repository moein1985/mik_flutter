import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hsmik/features/snmp/data/datasources/saved_snmp_device_local_data_source.dart';
import 'package:hsmik/features/snmp/data/models/saved_snmp_device_model.dart';
import 'package:hsmik/features/snmp/domain/entities/saved_snmp_device.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SavedSnmpDeviceLocalDataSourceImpl dataSource;

  setUp(() async {
    final factory = databaseFactoryFfi;
    db = await factory.openDatabase(inMemoryDatabasePath);

    // create table (similar to DatabaseHelper)
    await db.execute('''
      CREATE TABLE saved_snmp_devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        host TEXT NOT NULL,
        port INTEGER NOT NULL DEFAULT 161,
        community TEXT NOT NULL DEFAULT 'public',
        proprietary TEXT NOT NULL DEFAULT 'general',
        is_default INTEGER NOT NULL DEFAULT 0,
        last_connected TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_snmp_device_unique 
      ON saved_snmp_devices(host, port, community)
    ''');

    dataSource = SavedSnmpDeviceLocalDataSourceImpl(
      databaseFactory: () async => db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('CRUD and helpers work', () async {
    final now = DateTime.parse('2020-01-01T12:00:00Z');

    final model = SavedSnmpDeviceModel(
      id: null,
      name: 'T1',
      host: '10.0.0.1',
      port: 161,
      community: 'public',
      proprietary: DeviceVendor.general,
      isDefault: false,
      lastConnected: null,
      createdAt: now,
      updatedAt: now,
    );

    // save
    final saved = await dataSource.saveDevice(model);
    expect(saved.id, isNotNull);

    // deviceExists
    final exists = await dataSource.deviceExists('10.0.0.1', 161, 'public');
    expect(exists, true);

    // getAllDevices
    final all = await dataSource.getAllDevices();
    expect(all.length, 1);

    // getDefaultDevice -> none
    final def = await dataSource.getDefaultDevice();
    expect(def, isNull);

    // setDefaultDevice
    await dataSource.setDefaultDevice(saved.id!);
    final def2 = await dataSource.getDefaultDevice();
    expect(def2?.id, saved.id);

    // updateLastConnected
    await dataSource.updateLastConnected(saved.id!);
    final updated = await dataSource.getDeviceById(saved.id!);
    expect(updated?.lastConnected, isNotNull);

    // updateDevice
    final updatedModel = saved.copyWith(name: 'NewName');
    final updatedRes = await dataSource.updateDevice(SavedSnmpDeviceModel.fromEntity(updatedModel));
    expect(updatedRes.name, 'NewName');

    // delete
    final deleted = await dataSource.deleteDevice(saved.id!);
    expect(deleted, true);
  });
}
