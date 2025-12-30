import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/snmp/data/datasources/fake_snmp_data_source.dart';
import 'package:hsmik/features/snmp/data/repositories/snmp_repository_impl.dart';
import 'package:hsmik/features/snmp/data/datasources/snmp_data_source.dart';
import 'package:hsmik/core/errors/failures.dart';

class ThrowingDataSource extends SnmpDataSource {
  final Exception toThrow;
  ThrowingDataSource(this.toThrow);

  @override
  Future<Map<String, dynamic>> fetchDeviceInfo(String ip, String community, int port) async {
    throw toThrow;
  }

  @override
  Future<Map<int, Map<String, dynamic>>> fetchInterfacesData(String ip, String community, int port) async {
    throw toThrow;
  }
}

void main() {
  group('SnmpRepositoryImpl with fake data source', () {
    test('getDeviceInfo returns DeviceInfo on success', () async {
      final fake = FakeSnmpDataSource(seed: 1);
      final repo = SnmpRepositoryImpl(fake);

      final res = await repo.getDeviceInfo('10.0.0.1', 'public', 161);

      expect(res.isRight(), true);
      res.fold((l) => null, (r) {
        expect(r.sysName?.toLowerCase(), contains('cisco'));
        expect(r.sysDescr, isNotNull);
      });
    });

    test('getInterfaces returns list of interfaces and parses correctly', () async {
      final fake = FakeSnmpDataSource(seed: 2);
      final repo = SnmpRepositoryImpl(fake);

      final res = await repo.getInterfaces('10.0.0.1', 'public', 161);

      expect(res.isRight(), true);
      res.fold((l) => null, (list) {
        expect(list, isNotEmpty);
        expect(list.length, 24); // cisco profile
        final first = list.first;
        expect(first.name, startsWith('Gi1/0/'));
        expect(first.displayMacAddress, isNotNull);
      });
    });

    test('maps SnmpAuthenticationException to ServerFailure', () async {
      final ds = ThrowingDataSource(SnmpAuthenticationException('bad community'));
      final repo = SnmpRepositoryImpl(ds);

      final res = await repo.getDeviceInfo('10.0.0.2', 'public', 161);
      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<ServerFailure>()), (_) => null);

      final res2 = await repo.getInterfaces('10.0.0.2', 'public', 161);
      expect(res2.isLeft(), true);
      res2.fold((l) => expect(l, isA<ServerFailure>()), (_) => null);
    });

    test('maps NetworkException to NetworkFailure', () async {
      final ds = ThrowingDataSource(NetworkException('socket fail'));
      final repo = SnmpRepositoryImpl(ds);

      final res = await repo.getDeviceInfo('10.0.0.3', 'public', 161);
      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<NetworkFailure>()), (_) => null);
    });

    test('maps CancelledException to CancellationFailure', () async {
      final ds = ThrowingDataSource(CancelledException());
      final repo = SnmpRepositoryImpl(ds);

      final res = await repo.getDeviceInfo('10.0.0.4', 'public', 161);
      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<CancellationFailure>()), (_) => null);
    });
  });
}
