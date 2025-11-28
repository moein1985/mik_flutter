import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_active_user.dart';

void main() {
  group('HotspotActiveUser', () {
    const tActiveUser1 = HotspotActiveUser(
      id: '*1',
      user: 'user1',
      server: 'hotspot1',
      address: '192.168.1.100',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      loginBy: 'http-chap',
      uptime: '1d2h3m',
      sessionTimeLeft: '2h30m',
      idleTime: '5m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
    );

    const tActiveUser2 = HotspotActiveUser(
      id: '*1',
      user: 'user1',
      server: 'hotspot1',
      address: '192.168.1.100',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      loginBy: 'http-chap',
      uptime: '1d2h3m',
      sessionTimeLeft: '2h30m',
      idleTime: '5m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
    );

    const tActiveUser3 = HotspotActiveUser(
      id: '*2',
      user: 'user2',
      server: 'hotspot2',
      address: '192.168.1.101',
      macAddress: '11:22:33:44:55:66',
      loginBy: 'cookie',
      uptime: '2d4h6m',
      sessionTimeLeft: '1h15m',
      idleTime: '10m',
      bytesIn: '2048',
      bytesOut: '4096',
      packetsIn: '200',
      packetsOut: '400',
    );

    test('should be equal when all properties are the same', () {
      expect(tActiveUser1, equals(tActiveUser2));
    });

    test('should not be equal when properties differ', () {
      expect(tActiveUser1, isNot(equals(tActiveUser3)));
    });

    test('should have correct props', () {
      expect(tActiveUser1.props, [
        '*1',
        'user1',
        'hotspot1',
        '192.168.1.100',
        'AA:BB:CC:DD:EE:FF',
        'http-chap',
        '1d2h3m',
        '2h30m',
        '5m',
        '1024',
        '2048',
        '100',
        '200',
      ]);
    });
  });
}