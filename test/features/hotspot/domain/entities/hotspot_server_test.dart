import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_server.dart';

void main() {
  group('HotspotServer', () {
    final tServer1 = HotspotServer(
      id: '*1',
      name: 'hotspot1',
      interfaceName: 'ether1',
      addressPool: 'hs-pool',
      profile: 'default',
      disabled: false,
    );

    final tServer2 = HotspotServer(
      id: '*1',
      name: 'hotspot1',
      interfaceName: 'ether1',
      addressPool: 'hs-pool',
      profile: 'default',
      disabled: false,
    );

    final tServer3 = HotspotServer(
      id: '*2',
      name: 'hotspot2',
      interfaceName: 'ether2',
      addressPool: 'hs-pool-2',
      profile: 'premium',
      disabled: true,
    );

    test('should be equal when all properties are the same', () {
      expect(tServer1, equals(tServer2));
    });

    test('should not be equal when properties differ', () {
      expect(tServer1, isNot(equals(tServer3)));
    });

    test('should have correct props', () {
      expect(tServer1.props, [
        '*1',
        'hotspot1',
        'ether1',
        'hs-pool',
        'default',
        false,
      ]);
    });
  });
}