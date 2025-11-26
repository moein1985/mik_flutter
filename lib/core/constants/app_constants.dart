class AppConstants {
  // App Info
  static const String appName = 'MikroTik Manager';
  static const String appVersion = '1.0.0';

  // API
  static const int defaultApiPort = 8728;
  static const int defaultApiSslPort = 8729;
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration commandTimeout = Duration(seconds: 10);

  // Storage Keys
  static const String keyLastHost = 'last_host';
  static const String keyLastPort = 'last_port';
  static const String keyLastUsername = 'last_username';
  static const String keyPassword = 'password';
  static const String keyRememberCredentials = 'remember_credentials';
  static const String keyLanguage = 'language';

  // Default Values
  static const String defaultHost = '192.168.88.1';
  static const int defaultPort = 8728;
  static const String defaultUsername = 'admin';
}
