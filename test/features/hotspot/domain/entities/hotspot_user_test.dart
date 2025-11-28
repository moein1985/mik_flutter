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
      uptime: '1d2h3m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
      comment: 'test user',
      disabled: false,
    );

    final tUser2 = HotspotUser(
      id: '*1',
      name: 'user1',
      password: '123',
      profile: 'default',
      server: 'hotspot1',
      uptime: '1d2h3m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
      comment: 'test user',
      disabled: false,
    );

    final tUser3 = HotspotUser(
      id: '*2',
      name: 'user2',
      password: '456',
      profile: 'premium',
      server: 'hotspot2',
      uptime: '2d4h6m',
      bytesIn: '2048',
      bytesOut: '4096',
      packetsIn: '200',
      packetsOut: '400',
      comment: 'another user',
      disabled: true,
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
        '1d2h3m',
        '1024',
        '2048',
        '100',
        '200',
        'test user',
        false,
      ]);
    });
  });
}