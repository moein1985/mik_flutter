import 'package:sentry_flutter/sentry_flutter.dart';
import '../utils/logger.dart';

final _log = AppLogger.tag('SentryContext');

/// Manages Sentry context with router and device information
/// to provide better crash reports
class SentryContextManager {
  static void setRouterContext({
    required String host,
    required int port,
    required String username,
    required bool useSsl,
    String? routerOsVersion,
    String? boardName,
    String? model,
    String? uptime,
  }) {
    _log.d('Setting router context in Sentry');
    
    Sentry.configureScope((scope) {
      // Basic router info
      scope.setTag('router_host', host);
      scope.setTag('router_port', port.toString());
      scope.setTag('router_ssl', useSsl.toString());
      scope.setTag('router_username', username);
      
      // RouterOS details
      if (routerOsVersion != null) {
        scope.setTag('routeros_version', routerOsVersion);
      }
      if (boardName != null) {
        scope.setTag('router_board', boardName);
      }
      if (model != null) {
        scope.setTag('router_model', model);
      }
      
      // Additional context using Contexts API
      scope.setContexts('router', {
        'connection': '$host:$port',
        'uptime': uptime ?? 'unknown',
        'version': routerOsVersion ?? 'unknown',
        'board': boardName ?? 'unknown',
        'model': model ?? 'unknown',
      });
    });
    
    _log.i('Router context set: $host:$port (RouterOS: $routerOsVersion)');
  }
  
  static void clearRouterContext() {
    _log.d('Clearing router context from Sentry');
    
    Sentry.configureScope((scope) {
      scope.removeTag('router_host');
      scope.removeTag('router_port');
      scope.removeTag('router_ssl');
      scope.removeTag('router_username');
      scope.removeTag('routeros_version');
      scope.removeTag('router_board');
      scope.removeTag('router_model');
      scope.removeContexts('router');
    });
    
    _log.i('Router context cleared');
  }
  
  static void setUserContext({
    required String userId,
    String? username,
    String? email,
  }) {
    _log.d('Setting user context in Sentry');
    
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        username: username,
        email: email,
      ));
    });
  }
  
  static void clearUserContext() {
    _log.d('Clearing user context from Sentry');
    
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}
