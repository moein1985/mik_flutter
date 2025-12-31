/// Application Configuration
/// 
/// This class manages application-wide configuration including:
/// - Repository mode (mock vs real) for MikroTik, SNMP, and Asterisk
/// - Connection settings for Asterisk AMI and SSH
/// - Fake data settings for development
class AppConfig {
  // ===========================================================================
  // REPOSITORY CONFIGURATION
  // ===========================================================================

  /// Enable fake MikroTik repositories for development without a real router
  /// Set to `true` to use fake data, `false` to connect to real MikroTik router
  static const bool useMikrotikFakeRepositories = false;

  /// Enable fake SNMP repositories (used for tests & dev preview)
  /// Set to `true` to use fake data, `false` to connect to real SNMP devices
  static const bool useSnmpFakeRepositories = false;

  /// Enable fake Asterisk repositories for development without a real PBX server
  /// Set to `true` to use fake data, `false` to connect to real Asterisk server
  static const bool useAsteriskFakeRepositories = false;

  // ===========================================================================
  // ASTERISK AMI CONNECTION SETTINGS
  // ===========================================================================

  /// Default Asterisk AMI connection settings
  /// These are used when no saved settings exist
  static const String defaultAmiHost = '192.168.85.88';
  static const int defaultAmiPort = 5038;
  static const String defaultAmiUsername = 'moein_api';
  static const String defaultAmiSecret = '123456';

  // ===========================================================================
  // ASTERISK SSH CONNECTION SETTINGS
  // ===========================================================================

  /// Default SSH connection settings for Asterisk server
  /// SSH is used for:
  /// - CDR retrieval via Python script
  /// - Downloading call recordings
  /// - System info and AMI auto-setup
  static const String defaultSshHost = '192.168.85.88';
  static const int defaultSshPort = 22;
  static const String defaultSshUsername = 'moein';
  static const String defaultSshPassword = ''; // Will be loaded from secure storage
  static const String defaultRecordingsPath = '/var/spool/asterisk/monitor';

  // ===========================================================================
  // FAKE REPOSITORY SETTINGS
  // ===========================================================================

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

  /// SNMP-specific fake settings
  static const int fakeDefaultInterfaceCount = 8;
  static const bool fakeUseDeterministicData = true;
}

