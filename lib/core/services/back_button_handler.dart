import 'package:flutter/services.dart';
import '../utils/logger.dart';

class BackButtonHandler {
  static const MethodChannel _channel =
      MethodChannel('com.example.hsmik/back_button');
  
  static Function()? _onBackPressed;

  /// Initialize the back button handler
  static Future<void> initialize() async {
    AppLogger.d('Initializing BackButtonHandler', tag: 'BackButtonHandler');
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from native (Android)
  static Future<void> _handleMethodCall(MethodCall call) async {
    AppLogger.d('Received method call: ${call.method}', tag: 'BackButtonHandler');
    switch (call.method) {
      case 'onBackPressed':
        AppLogger.d('onBackPressed received from native', tag: 'BackButtonHandler');
        if (_onBackPressed != null) {
          AppLogger.d('Calling callback', tag: 'BackButtonHandler');
          _onBackPressed?.call();
        } else {
          AppLogger.w('No callback registered!', tag: 'BackButtonHandler');
        }
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Set the callback for when back button is pressed
  static void setOnBackPressed(Function()? callback) {
    AppLogger.d('Setting callback: ${callback != null ? "registered" : "removed"}', tag: 'BackButtonHandler');
    _onBackPressed = callback;
  }

  /// Enable or disable back button interception
  static Future<void> setInterceptBack(bool intercept) async {
    try {
      AppLogger.d('Setting intercept to: $intercept', tag: 'BackButtonHandler');
      await _channel.invokeMethod('setInterceptBack', {
        'intercept': intercept,
      });
    } catch (e) {
      AppLogger.e('Error setting intercept: $e', tag: 'BackButtonHandler');
      // Ignore on non-Android platforms
    }
  }

  /// Dispose the handler
  static void dispose() {
    AppLogger.d('Disposing BackButtonHandler', tag: 'BackButtonHandler');
    _onBackPressed = null;
  }
}
