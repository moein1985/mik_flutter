import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/data/models/hotspot_server_model.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_server.dart';

void main() {
  group('HotspotServerModel', () {
    test('should be a subclass of HotspotServer', () {
      // Arrange
      final model = HotspotServerModel.fromMap({
        '.id': '*1',
        'name': 'hotspot1',
        'interface': 'ether1',
        'address-pool': 'hs-pool',
        'disabled': 'false',
      });

      // Act & Assert
      expect(model, isA<HotspotServer>());
    });

    test('should return a valid model from Map', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'hotspot1',
        'interface': 'ether1',
        'address-pool': 'hs-pool',
        'profile': 'default',
        'disabled': 'false',
      };

      // Act
      final result = HotspotServerModel.fromMap(map);

      // Assert
      expect(result, isA<HotspotServer>());
      expect(result.id, '*1');
      expect(result.name, 'hotspot1');
      expect(result.interfaceName, 'ether1');
      expect(result.addressPool, 'hs-pool');
      expect(result.profile, 'default');
      expect(result.disabled, false);
    });

    test('should handle null profile', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'hotspot1',
        'interface': 'ether1',
        'address-pool': 'hs-pool',
        'disabled': 'false',
      };

      // Act
      final result = HotspotServerModel.fromMap(map);

      // Assert
      expect(result.profile, null);
    });

    test('should handle disabled true', () {
      // Arrange
      final Map<String, dynamic> map = {
        '.id': '*1',
        'name': 'hotspot1',
        'interface': 'ether1',
        'address-pool': 'hs-pool',
        'disabled': 'true',
      };

      // Act
      final result = HotspotServerModel.fromMap(map);

      // Assert
      expect(result.disabled, true);
    });
  });
}