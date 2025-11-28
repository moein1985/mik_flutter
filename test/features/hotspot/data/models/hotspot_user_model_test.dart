import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/data/models/hotspot_user_model.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_user.dart';

void main() {
  group('HotspotUserModel', () {
    test('should be a subclass of HotspotUser', () {
      // Arrange
      final model = HotspotUserModel.fromMap({
        '.id': '*1',
        'name': 'user1',
        'disabled': 'false',
      });

      // Act & Assert
      expect(model, isA<HotspotUser>());
    });

    test('should return a valid model from Map', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'user1',
        'password': '123',
        'profile': 'default',
        'server': 'hotspot1',
        'uptime': '1d2h3m',
        'bytes-in': '1024',
        'bytes-out': '2048',
        'packets-in': '100',
        'packets-out': '200',
        'comment': 'test user',
        'disabled': 'false',
      };

      // Act
      final result = HotspotUserModel.fromMap(map);

      // Assert
      expect(result, isA<HotspotUser>());
      expect(result.id, '*1');
      expect(result.name, 'user1');
      expect(result.password, '123');
      expect(result.profile, 'default');
      expect(result.server, 'hotspot1');
      expect(result.uptime, '1d2h3m');
      expect(result.bytesIn, '1024');
      expect(result.bytesOut, '2048');
      expect(result.packetsIn, '100');
      expect(result.packetsOut, '200');
      expect(result.comment, 'test user');
      expect(result.disabled, false);
    });

    test('should handle null fields', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'user1',
        'disabled': 'false',
      };

      // Act
      final result = HotspotUserModel.fromMap(map);

      // Assert
      expect(result.password, null);
      expect(result.profile, null);
      expect(result.server, null);
      expect(result.uptime, null);
      expect(result.bytesIn, null);
      expect(result.bytesOut, null);
      expect(result.packetsIn, null);
      expect(result.packetsOut, null);
      expect(result.comment, null);
    });

    test('should return a valid Map from model', () {
      // Arrange
      final model = HotspotUserModel(
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

      // Act
      final result = model.toMap();

      // Assert
      expect(result, {
        '.id': '*1',
        'name': 'user1',
        'password': '123',
        'profile': 'default',
        'server': 'hotspot1',
        'uptime': '1d2h3m',
        'bytes-in': '1024',
        'bytes-out': '2048',
        'packets-in': '100',
        'packets-out': '200',
        'comment': 'test user',
        'disabled': 'false',
      });
    });

    test('should handle null fields in toMap', () {
      // Arrange
      final model = HotspotUserModel(
        id: '*1',
        name: 'user1',
        disabled: false,
      );

      // Act
      final result = model.toMap();

      // Assert
      expect(result, {
        '.id': '*1',
        'name': 'user1',
        'disabled': 'false',
      });
    });
  });
}