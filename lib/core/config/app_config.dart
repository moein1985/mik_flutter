/// Application configuration
/// 
/// Controls various app behaviors including fake data mode for development
class AppConfig {
  /// Enable fake repositories for development without a real router
  /// Set to `true` to use fake data, `false` to connect to real MikroTik router
  static const bool useMikrotikFakeRepositories = false;
  
  /// Network delay simulation for fake repositories
  /// Simulates realistic network latency
  static const Duration fakeNetworkDelay = Duration(milliseconds: 800);
  
  /// Error rate for fake repositories (0.0 to 1.0)
  /// 0.1 = 10% chance of random errors for testing error handling
  static const double fakeErrorRate = 0.0; // Disabled for stable testing
  
  /// Minimum delay for fake operations
  static const Duration fakeMinDelay = Duration(milliseconds: 300);
  
  /// Maximum delay for fake operations
  static const Duration fakeMaxDelay = Duration(milliseconds: 1200);
}
