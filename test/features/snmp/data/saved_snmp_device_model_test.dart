import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/snmp/data/models/saved_snmp_device_model.dart';
import 'package:hsmik/features/snmp/domain/entities/saved_snmp_device.dart';

void main() {
  final now = DateTime.parse('2020-01-01T12:00:00Z');

  test('fromMap and toMap should serialize/deserialize correctly', () {
    final map = {
      'id': 7,
      'name': 'Dev',
      'host': '10.0.0.1',
      'port': 161,
      'community': 'public',
      'proprietary': 'asterisk',
      'is_default': 1,
      'last_connected': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final model = SavedSnmpDeviceModel.fromMap(map);

    expect(model.id, 7);
    expect(model.name, 'Dev');
    expect(model.host, '10.0.0.1');
    expect(model.port, 161);
    expect(model.community, 'public');
    expect(model.proprietary, DeviceVendor.asterisk);
    expect(model.isDefault, true);
    expect(model.lastConnected, now);
    expect(model.createdAt, now);
    expect(model.updatedAt, now);

    final serialized = model.toMap();
    expect(serialized['id'], 7);
    expect(serialized['name'], 'Dev');
    expect(serialized['proprietary'], 'asterisk');
    expect(serialized['is_default'], 1);
  });

  test('toInsertMap should not contain id', () {
    final model = SavedSnmpDeviceModel(
      id: null,
      name: 'New',
      host: '127.0.0.1',
      port: 161,
      community: 'pub',
      proprietary: DeviceVendor.general,
      isDefault: false,
      lastConnected: null,
      createdAt: now,
      updatedAt: now,
    );

    final insertMap = model.toInsertMap();
    expect(insertMap.containsKey('id'), false);
    expect(insertMap['name'], 'New');
  });
}
