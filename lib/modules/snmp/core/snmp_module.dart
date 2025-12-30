import 'package:flutter/material.dart';
import '../../_shared/base_device_module.dart';
import '../../../features/snmp/presentation/pages/snmp_dashboard_page.dart';

/// SNMP Assist Module
/// 
/// General-purpose SNMP monitoring module supporting multiple vendors:
/// - General: Any SNMP-enabled device (routers, switches, printers, UPS, etc.)
/// - Asterisk: PBX-specific monitoring (calls, channels, etc.)
/// - Cisco: (via SNMP MIB)
/// - Microsoft: Windows Server (via SNMP)
/// 
/// This module uses core SNMP protocol implementation from `core/protocols/snmp/`
/// and vendor-specific extensions from `sdks/snmp_vendor_extensions/`.
class SNMPModule extends BaseDeviceModule {
  @override
  String get id => 'snmp';

  @override
  String get displayName => 'SNMP Assist';

  @override
  String get description => 'Monitor any SNMP-enabled device (routers, switches, servers, PBX, etc.)';

  @override
  IconData get icon => Icons.device_hub;

  @override
  Color get primaryColor => Colors.green;

  @override
  bool get requiresAuth => false; // SNMP uses community string, not app-level auth

  @override
  List<String> get supportedProtocols => [
    'SNMP v1',
    'SNMP v2c',
    // 'SNMP v3', // Future support
  ];

  @override
  Widget getDashboardPage() {
    return const SnmpDashboardPage();
  }

  @override
  Widget? getAuthPage() {
    // SNMP uses community string (provided per-device), not app-level authentication
    return null;
  }

  @override
  String getRouteBasePath() {
    return '/snmp';
  }

  @override
  List<Map<String, dynamic>> getFeatureRoutes() {
    return [
      {
        'path': '/snmp',
        'name': 'SNMP Dashboard',
        'icon': Icons.dashboard,
        'builder': (BuildContext context) => const SnmpDashboardPage(),
      },
      // Future features:
      // {
      //   'path': '/snmp/devices',
      //   'name': 'Saved Devices',
      //   'icon': Icons.devices,
      //   'builder': (context) => SnmpDevicesPage(),
      // },
    ];
  }

  @override
  Widget? getSettingsPage() {
    // TODO: Create SNMP settings page (default community, timeout, retries, etc.)
    return null;
  }

  @override
  Widget? getHelpPage() {
    // TODO: Create SNMP help page with setup instructions
    return null;
  }

  @override
  Future<void> initialize() async {
    // SNMP module initialization (if needed)
    // All dependencies already registered in injection_container.dart
  }

  @override
  Future<void> dispose() async {
    // SNMP cleanup (if needed)
  }

  @override
  String get version => '1.0.0';

  @override
  bool get isBeta => false;

  @override
  String? get minDeviceVersion => null; // Supports all SNMP v1/v2c devices

  @override
  List<String>? get supportedDevices => [
    'Any SNMP-enabled device',
    'Cisco routers/switches',
    'MikroTik RouterOS',
    'Asterisk PBX',
    'Windows Server',
    'Linux servers',
    'Network printers',
    'UPS devices',
  ];
}
