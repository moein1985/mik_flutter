import 'package:flutter/material.dart';

/// Base interface for all device modules in the application.
/// 
/// This interface defines the common contract that all vendor-specific modules
/// (MikroTik, SNMP, Cisco, etc.) must implement to integrate with the application.
/// 
/// Each module represents a vendor-specific network device management implementation.
abstract class BaseDeviceModule {
  /// Unique identifier for the module (e.g., 'mikrotik', 'snmp', 'cisco')
  String get id;

  /// Display name of the module shown to users (e.g., 'MikroTik Assist')
  String get displayName;

  /// Brief description of the module's capabilities
  String get description;

  /// Icon representing the module in the UI
  IconData get icon;

  /// Primary color theme for the module
  Color get primaryColor;

  /// Whether this module requires authentication before accessing features
  bool get requiresAuth;

  /// List of supported protocols by this module
  /// Examples: ['RouterOS API'], ['SNMP v1/v2c'], ['SNMP', 'NETCONF', 'SSH']
  List<String> get supportedProtocols;

  /// Returns the main dashboard/landing page for this module
  /// 
  /// This is the entry point users see when they select this module
  Widget getDashboardPage();

  /// Returns the authentication/login page for this module
  /// 
  /// Returns null if [requiresAuth] is false or auth is handled globally
  Widget? getAuthPage();

  /// Returns the route path for the module's main page
  /// Example: '/mikrotik', '/snmp', '/cisco'
  String getRouteBasePath();

  /// Returns a list of feature routes specific to this module
  /// 
  /// Each entry should be a map with:
  /// - 'path': The route path (e.g., '/mikrotik/firewall')
  /// - 'name': Display name (e.g., 'Firewall')
  /// - 'icon': IconData for the feature
  /// - 'builder': Widget Function(BuildContext) to build the page
  /// 
  /// Example:
  /// ```dart
  /// [
  ///   {
  ///     'path': '/mikrotik/firewall',
  ///     'name': 'Firewall',
  ///     'icon': Icons.security,
  ///     'builder': (context) => FirewallPage(),
  ///   }
  /// ]
  /// ```
  List<Map<String, dynamic>> getFeatureRoutes();

  /// Returns configuration options/settings for this module
  /// 
  /// Returns null if the module has no specific settings
  Widget? getSettingsPage();

  /// Optional: Returns a help/documentation page for this module
  Widget? getHelpPage() => null;

  /// Optional: Called when the module is initialized
  /// 
  /// Use this for any setup logic (e.g., registering services, loading config)
  Future<void> initialize() async {}

  /// Optional: Called when the module is being disposed
  /// 
  /// Use this for cleanup logic
  Future<void> dispose() async {}

  /// Optional: Returns the version of the module implementation
  String get version => '1.0.0';

  /// Optional: Indicates if the module is in beta/experimental state
  bool get isBeta => false;

  /// Optional: Indicates if the module is enabled
  /// Modules can be disabled in settings or based on subscription tier
  bool get isEnabled => true;

  /// Optional: Returns minimum required device/firmware version
  /// Returns null if there's no specific requirement
  String? get minDeviceVersion => null;

  /// Optional: Returns a list of supported device models/types
  /// Returns null if the module supports all devices of its type
  List<String>? get supportedDevices => null;
}

/// Module metadata for display in module selection UI
class ModuleMetadata {
  final String id;
  final String displayName;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final bool requiresAuth;
  final List<String> supportedProtocols;
  final bool isBeta;
  final String version;

  const ModuleMetadata({
    required this.id,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.requiresAuth,
    required this.supportedProtocols,
    this.isBeta = false,
    this.version = '1.0.0',
  });

  factory ModuleMetadata.fromModule(BaseDeviceModule module) {
    return ModuleMetadata(
      id: module.id,
      displayName: module.displayName,
      description: module.description,
      icon: module.icon,
      primaryColor: module.primaryColor,
      requiresAuth: module.requiresAuth,
      supportedProtocols: module.supportedProtocols,
      isBeta: module.isBeta,
      version: module.version,
    );
  }
}
