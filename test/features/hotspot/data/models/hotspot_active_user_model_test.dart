import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/data/models/hotspot_active_user_model.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_active_user.dart';

void main() {
  group('HotspotActiveUserModel', () {
    test('should be a subclass of HotspotActiveUser', () {
      // Arrange
      final model = HotspotActiveUserModel.fromMap({
        '.id': '*1',
        'user': 'user1',
        'server': 'hotspot1',
        'address': '192.168.1.100',
        'mac-address': 'AA:BB:CC:DD:EE:FF',
        'login-by': 'http-chap',
        'uptime': '1d2h3m',
        'session-time-left': '2h30m',
        'idle-time': '5m',
        'bytes-in': '1024',
        'bytes-out': '2048',
        'packets-in': '100',
        'packets-out': '200',
      });

      // Act & Assert
      expect(model, isA<HotspotActiveUser>());
    });

    test('should return a valid model from Map', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'user': 'user1',
        'server': 'hotspot1',
        'address': '192.168.1.100',
        'mac-address': 'AA:BB:CC:DD:EE:FF',
        'login-by': 'http-chap',
        'uptime': '1d2h3m',
        'session-time-left': '2h30m',
        'idle-time': '5m',
        'bytes-in': '1024',
        'bytes-out': '2048',
        'packets-in': '100',
        'packets-out': '200',
      };

      // Act
      final result = HotspotActiveUserModel.fromMap(map);

      // Assert
      expect(result, isA<HotspotActiveUser>());
      expect(result.id, '*1');
      expect(result.user, 'user1');
      expect(result.server, 'hotspot1');
      expect(result.address, '192.168.1.100');
      expect(result.macAddress, 'AA:BB:CC:DD:EE:FF');
      expect(result.loginBy, 'http-chap');
      expect(result.uptime, '1d2h3m');
      expect(result.sessionTimeLeft, '2h30m');
      expect(result.idleTime, '5m');
      expect(result.bytesIn, '1024');
      expect(result.bytesOut, '2048');
      expect(result.packetsIn, '100');
      expect(result.packetsOut, '200');
    });
  });
}