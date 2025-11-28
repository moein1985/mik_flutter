import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_profile.dart';

void main() {
  group('HotspotProfile', () {
    const tProfile1 = HotspotProfile(
      id: '*1',
      name: 'default',
      sessionTimeout: '1d',
      idleTimeout: '30m',
      sharedUsers: '1',
      rateLimit: '1M/1M',
      keepaliveTimeout: '10m',
      statusAutorefresh: '1m',
      onLogin: 'script1',
      onLogout: 'script2',
    );

    const tProfile2 = HotspotProfile(
      id: '*1',
      name: 'default',
      sessionTimeout: '1d',
      idleTimeout: '30m',
      sharedUsers: '1',
      rateLimit: '1M/1M',
      keepaliveTimeout: '10m',
      statusAutorefresh: '1m',
      onLogin: 'script1',
      onLogout: 'script2',
    );

    const tProfile3 = HotspotProfile(
      id: '*2',
      name: 'premium',
      sessionTimeout: '2d',
      idleTimeout: '1h',
      sharedUsers: '5',
      rateLimit: '10M/10M',
      keepaliveTimeout: '5m',
      statusAutorefresh: '30s',
      onLogin: 'script3',
      onLogout: 'script4',
    );

    test('should be equal when all properties are the same', () {
      expect(tProfile1, equals(tProfile2));
    });

    test('should not be equal when properties differ', () {
      expect(tProfile1, isNot(equals(tProfile3)));
    });

    test('should have correct props', () {
      expect(tProfile1.props, [
        '*1',
        'default',
        '1d',
        '30m',
        '1',
        '1M/1M',
        '10m',
        '1m',
        'script1',
        'script2',
      ]);
    });
  });
}