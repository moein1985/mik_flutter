import 'package:flutter/material.dart';
import '../../_shared/base_device_module.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';

/// MikroTik Assist Module
/// 
/// Complete RouterOS management suite with 13+ features:
/// 1. System Dashboard - Resources monitoring
/// 2. Firewall - Filter rules, NAT, Mangle
/// 3. HotSpot - User management, billing
/// 4. DHCP Server - IP address management
/// 5. Interfaces - Network interface configuration
/// 6. IP Addresses - IP assignment
/// 7. Wireless - WiFi configuration
/// 8. Certificates - SSL/TLS management
/// 9. IP Services - Port/service configuration
/// 10. Let's Encrypt - Automated certificates
/// 11. Cloud - RouterOS Cloud backup
/// 12. Queues - Traffic shaping/QoS
/// 13. Backup - Configuration backup/restore
/// 14. Logs - System logs viewer
/// 15. Tools - Ping, Traceroute, DNS lookup
/// 
/// Protocol: RouterOS API (proprietary)
/// Compatible with: RouterOS 6.x, 7.x
class MikroTikModule extends BaseDeviceModule {
  @override
  String get id => 'mikrotik';

  @override
  String get displayName => 'MikroTik Assist';

  @override
  String get description => 'Complete RouterOS management suite with 13+ advanced features';

  @override
  IconData get icon => Icons.router;

  @override
  Color get primaryColor => const Color(0xFF293239); // MikroTik brand color

  @override
  bool get requiresAuth => true; // Requires router-level authentication

  @override
  List<String> get supportedProtocols => [
    'RouterOS API',
  ];

  @override
  Widget getDashboardPage() {
    return const DashboardPage();
  }

  @override
  Widget? getAuthPage() {
    // Authentication handled by existing auth feature
    return null;
  }

  @override
  String getRouteBasePath() {
    return '/mikrotik';
  }

  @override
  List<Map<String, dynamic>> getFeatureRoutes() {
    return [
      {
        'path': '/mikrotik',
        'name': 'Dashboard',
        'icon': Icons.dashboard,
        'builder': (BuildContext context) => const DashboardPage(),
      },
      // Note: Other routes already registered in app_router.dart
      // This list is for module metadata purposes
    ];
  }

  @override
  Widget? getSettingsPage() {
    // TODO: Create MikroTik-specific settings page
    // (e.g., default timeout, API port, etc.)
    return null;
  }

  @override
  Widget? getHelpPage() {
    // TODO: Create MikroTik help page with setup instructions
    return null;
  }

  @override
  Future<void> initialize() async {
    // MikroTik module initialization
    // All dependencies already registered in injection_container.dart
  }

  @override
  Future<void> dispose() async {
    // MikroTik cleanup (if needed)
  }

  @override
  String get version => '1.0.0';

  @override
  bool get isBeta => false;

  @override
  String? get minDeviceVersion => 'RouterOS 6.0';

  @override
  List<String>? get supportedDevices => [
    'MikroTik RouterBOARD devices',
    'RouterOS CHR (Cloud Hosted Router)',
    'RouterOS x86',
  ];
}
