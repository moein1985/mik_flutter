import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/snmp/data/datasources/fake_snmp_data_source.dart';
import 'package:hsmik/features/snmp/data/datasources/snmp_data_source.dart';

void main() {
  group('FakeSnmpDataSource basic behavior', () {
    test('fetchDeviceInfo returns profile-like fields', () async {
      final fake = FakeSnmpDataSource(seed: 1);
      final data = await fake.fetchDeviceInfo('10.0.0.5', 'public', 161);

      expect(data.containsKey('sysName'), true);
      expect(data.containsKey('sysDescr'), true);
      expect(data.containsKey('sysObjectID'), true);
    });

    test('fetchInterfacesData returns a non-empty map', () async {
      final fake = FakeSnmpDataSource(seed: 2);
      final data = await fake.fetchInterfacesData('10.0.0.7', 'public', 161);

      expect(data.isNotEmpty, true);
      expect(data.values.first.containsKey('name'), true);
      expect(data.values.first.containsKey('physAddress'), true);
    });

    test('cancelCurrentOperation triggers CancelledException', () async {
      final fake = FakeSnmpDataSource(seed: 3);
      // schedule a long fetch but cancel immediately
      final future = fake.fetchInterfacesData('10.0.0.12', 'public', 161);
      fake.cancelCurrentOperation();

      expect(() async => await future, throwsA(isA<CancelledException>()));
    });
  });
}
