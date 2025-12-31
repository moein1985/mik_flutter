import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../_shared/base_device_module.dart';
import '../../../features/asterisk/presentation/pages/asterisk_dashboard_page.dart';
import '../../../features/asterisk/core/injection_container.dart' as asterisk_di;
import '../../../core/config/app_config.dart';

/// Asterisk PBX Module
/// 
/// Complete Asterisk PBX management solution with real-time monitoring:
/// 1. Dashboard - Live system stats and monitoring
/// 2. Extensions - Extension management and status
/// 3. Active Calls - Real-time call monitoring
/// 4. Call Control - Originate, hangup, transfer, spy calls
/// 5. Queues - Queue status and agent management
/// 6. CDR Reports - Call detail records with CSV export
/// 7. Trunks - SIP/IAX trunk monitoring
/// 8. Parking - Call parking lot management
/// 9. System Resources - CPU, memory, disk monitoring
/// 10. Background Notifications - Real-time call alerts
/// 
/// Protocols: Asterisk Manager Interface (AMI), SSH
/// Compatible with: Asterisk 11+, 13+, 16+, 18+, 20+
class AsteriskModule extends BaseDeviceModule {
  bool _initialized = false;

  @override
  String get id => 'asterisk';

  @override
  String get displayName => 'Asterisk PBX';

  @override
  String get description => 'Complete Asterisk PBX management with real-time call monitoring and control';

  @override
  IconData get icon => Icons.phone_in_talk;

  @override
  Color get primaryColor => const Color(0xFFFF6600); // Asterisk orange

  @override
  bool get requiresAuth => true; // Requires AMI authentication

  @override
  List<String> get supportedProtocols => [
    'Asterisk Manager Interface (AMI)',
    'SSH',
  ];

  @override
  Future<void> initialize() async {
    if (!_initialized) {
      // Register Asterisk dependencies with GetIt
      await asterisk_di.setupAsteriskDependencies(
        GetIt.instance,
        useMock: AppConfig.useAsteriskFakeRepositories,
      );
      _initialized = true;
    }
  }

  @override
  Widget getDashboardPage() {
    return const AsteriskDashboardPage();
  }

  @override
  Widget? getAuthPage() {
    // Uses global authentication system
    return null;
  }

  @override
  String getRouteBasePath() {
    return '/asterisk';
  }

  @override
  List<Map<String, dynamic>> getFeatureRoutes() {
    return [
      {
        'path': '/asterisk/dashboard',
        'name': 'Dashboard',
        'icon': Icons.dashboard,
        'description': 'System overview and live statistics',
      },
      {
        'path': '/asterisk/extensions',
        'name': 'Extensions',
        'icon': Icons.people,
        'description': 'Manage and monitor extensions',
      },
      {
        'path': '/asterisk/calls',
        'name': 'Active Calls',
        'icon': Icons.call,
        'description': 'Monitor and control active calls',
      },
      {
        'path': '/asterisk/queues',
        'name': 'Queues',
        'icon': Icons.queue,
        'description': 'Queue status and agent management',
      },
      {
        'path': '/asterisk/cdr',
        'name': 'CDR Reports',
        'icon': Icons.assessment,
        'description': 'Call detail records and reports',
      },
      {
        'path': '/asterisk/trunks',
        'name': 'Trunks',
        'icon': Icons.compare_arrows,
        'description': 'SIP/IAX trunk monitoring',
      },
      {
        'path': '/asterisk/parking',
        'name': 'Parking',
        'icon': Icons.local_parking,
        'description': 'Call parking lot management',
      },
      {
        'path': '/asterisk/originate',
        'name': 'Originate Call',
        'icon': Icons.phone_forwarded,
        'description': 'Initiate outbound calls',
      },
      {
        'path': '/asterisk/settings',
        'name': 'Settings',
        'icon': Icons.settings,
        'description': 'Module configuration',
      },
    ];
  }

  @override
  Widget? getSettingsPage() {
    // Will implement settings page later
    return null;
  }

  @override
  String get version => '1.0.0';

  @override
  bool get isBeta => false;

  @override
  bool get isEnabled => true;

  @override
  String? get minDeviceVersion => 'Asterisk 11+';

  @override
  List<String>? get supportedDevices => [
    'Asterisk PBX',
    'FreePBX',
    'Issabel PBX',
    'Elastix',
    'AsteriskNOW',
  ];
}
