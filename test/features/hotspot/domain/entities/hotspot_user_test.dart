import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_user.dart';

void main() {
  group('HotspotUser', () {
    final tUser1 = HotspotUser(
      id: '*1',
      name: 'user1',
      password: '123',
      profile: 'default',
      server: 'hotspot1',
      comment: 'test user',
      disabled: false,
      limitUptime: '1h',
      limitBytesIn: '1073741824',
      limitBytesOut: '536870912',
      limitBytesTotal: '2147483648',
      uptime: '1d2h3m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
    );

    final tUser2 = HotspotUser(
      id: '*1',
      name: 'user1',
      password: '123',
      profile: 'default',
      server: 'hotspot1',
      comment: 'test user',
      disabled: false,
      limitUptime: '1h',
      limitBytesIn: '1073741824',
      limitBytesOut: '536870912',
      limitBytesTotal: '2147483648',
      uptime: '1d2h3m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
    );

    final tUser3 = HotspotUser(
      id: '*2',
      name: 'user2',
      password: '456',
      profile: 'premium',
      server: 'hotspot2',
      comment: 'another user',
      disabled: true,
      uptime: '2d4h6m',
      bytesIn: '2048',
      bytesOut: '4096',
      packetsIn: '200',
      packetsOut: '400',
    );

    test('should be equal when all properties are the same', () {
      expect(tUser1, equals(tUser2));
    });

    test('should not be equal when properties differ', () {
      expect(tUser1, isNot(equals(tUser3)));
    });

    test('should have correct props', () {
      expect(tUser1.props, [
        '*1',
        'user1',
        '123',
        'default',
        'hotspot1',
        'test user',
        false,
        '1h',
        '1073741824',
        '536870912',
        '2147483648',
        '1d2h3m',
        '1024',
        '2048',
        '100',
        '200',
      ]);
    });

    test('hasLimits should return true when limits are set', () {
      expect(tUser1.hasLimits, isTrue);
    });

    test('hasLimits should return false when no limits are set', () {
      expect(tUser3.hasLimits, isFalse);
    });

    test('hasStatistics should return true when statistics exist', () {
      expect(tUser1.hasStatistics, isTrue);
    });

    test('hasStatistics should return false when no statistics', () {
      final userWithoutStats = HotspotUser(
        id: '*3',
        name: 'newuser',
        disabled: false,
      );
      expect(userWithoutStats.hasStatistics, isFalse);
    });
  });
}