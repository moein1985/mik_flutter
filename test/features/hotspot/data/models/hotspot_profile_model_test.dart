import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/data/models/hotspot_profile_model.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_profile.dart';

void main() {
  group('HotspotProfileModel', () {
    test('should be a subclass of HotspotProfile', () {
      // Arrange
      final model = HotspotProfileModel.fromMap({
        '.id': '*1',
        'name': 'default',
      });

      // Act & Assert
      expect(model, isA<HotspotProfile>());
    });

    test('should return a valid model from Map', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'default',
        'session-timeout': '1d',
        'idle-timeout': '30m',
        'shared-users': '1',
        'rate-limit': '1M/1M',
        'keepalive-timeout': '10m',
        'status-autorefresh': '1m',
        'on-login': 'script1',
        'on-logout': 'script2',
      };

      // Act
      final result = HotspotProfileModel.fromMap(map);

      // Assert
      expect(result, isA<HotspotProfile>());
      expect(result.id, '*1');
      expect(result.name, 'default');
      expect(result.sessionTimeout, '1d');
      expect(result.idleTimeout, '30m');
      expect(result.sharedUsers, '1');
      expect(result.rateLimit, '1M/1M');
      expect(result.keepaliveTimeout, '10m');
      expect(result.statusAutorefresh, '1m');
      expect(result.onLogin, 'script1');
      expect(result.onLogout, 'script2');
    });

    test('should handle null fields', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'default',
      };

      // Act
      final result = HotspotProfileModel.fromMap(map);

      // Assert
      expect(result.sessionTimeout, null);
      expect(result.idleTimeout, null);
      expect(result.sharedUsers, null);
      expect(result.rateLimit, null);
      expect(result.keepaliveTimeout, null);
      expect(result.statusAutorefresh, null);
      expect(result.onLogin, null);
      expect(result.onLogout, null);
    });
  });
}