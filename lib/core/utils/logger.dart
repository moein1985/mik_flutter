import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  static LogLevel _minLevel = LogLevel.debug;
  static bool _enabled = true;

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  static void enable() => _enabled = true;
  static void disable() => _enabled = false;

  static void _log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || level.index < _minLevel.index) return;

    final prefix = _getPrefix(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    
    final logMessage = '[$timestamp] $prefix $tagStr$message';
    
    // Print to console
    print(logMessage);
    
    // Also log to developer console for better debugging
    developer.log(
      message,
      name: tag ?? 'App',
      level: _getDeveloperLevel(level),
      error: error,
      stackTrace: stackTrace,
    );

    if (error != null) {
      print('  Error: $error');
    }
    if (stackTrace != null) {
      print('  StackTrace: $stackTrace');
    }
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }

  static int _getDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  // Convenience methods
  static void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(message, level: LogLevel.debug, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(message, level: LogLevel.info, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(message, level: LogLevel.warning, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(message, level: LogLevel.error, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Tagged logger factory
  static TaggedLogger tag(String tag) => TaggedLogger(tag);
}

class TaggedLogger {
  final String _tag;

  TaggedLogger(this._tag);

  void d(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.d(message, tag: _tag, error: error, stackTrace: stackTrace);
  }

  void i(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.i(message, tag: _tag, error: error, stackTrace: stackTrace);
  }

  void w(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.w(message, tag: _tag, error: error, stackTrace: stackTrace);
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.e(message, tag: _tag, error: error, stackTrace: stackTrace);
  }
}
