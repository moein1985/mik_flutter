# 🔧 Refactoring Proposal: Multi-Module Architecture

## 📋 Executive Summary

**Current State:** 
- **MikroTik Module**: 13 separate feature modules (Dashboard, Firewall, Hotspot, DHCP, etc.)
- **SNMP Module**: Independent module with General device support + Asterisk vendor-specific implementation
- **Future Vendors**: Cisco, Microsoft, ESXi (not yet implemented)

**Proposed State:** 
- Clear modular architecture with each vendor as independent module
- Shared SDK layer for reusable components (Cisco SDK, SNMP protocol, etc.)
- Consistent documentation structure in `docs/modules/` per module
- Core protocol implementations separated from vendor-specific logic

**Timeline:** 4-6 working days  
**Risk Level:** Low-Medium (SNMP already exists as separate module)  
**Benefits:** High scalability, SDK reusability, better maintainability, easier testing

---

## 🎯 Goals

1. **Consistency**: All network device vendors follow same architectural pattern
2. **Scalability**: Easy to add new vendors (VMware ESXi, Ubiquiti, Aruba, etc.)
3. **SDK Reusability**: Shared SDKs (e.g., Cisco SDK) usable across multiple modules
4. **Maintainability**: Clear separation of concerns with proper documentation
5. **Testability**: Each module can be tested independently
6. **Team Collaboration**: Different developers can work on different modules
7. **Documentation**: Structured docs in `docs/modules/` for each module

---

## 📐 Proposed Architecture

### High-Level Overview

```
mik_flutter/
├── lib/
│   ├── core/              ← Core infrastructure
│   ├── sdks/              ← Reusable SDKs (NEW)
│   ├── modules/           ← Vendor-specific modules (NEW)
│   └── features/          ← Cross-cutting features
│
└── docs/                  ← Documentation (NEW)
    ├── architecture/
    └── modules/
        ├── mikrotik/
        ├── snmp/
        ├── cisco/
        ├── asterisk/
        ├── microsoft/
        └── esxi/
```

### Directory Structure

```
lib/
├── core/
│   ├── network/
│   │   └── routeros_client_v2.dart         ← MikroTik-specific
│   ├── protocols/                           ← Protocol implementations
│   │   └── snmp/
│   │       ├── snmp_client.dart            ← Base SNMP client
│   │       ├── snmp_session.dart
│   │       └── models/
│   │           ├── snmp_device.dart
│   │           ├── snmp_metric.dart
│   │           └── snmp_oid.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   └── utils/
│
├── sdks/                                     ← NEW: Reusable SDK layer
│   │
│   ├── cisco/                               ← Cisco SDK (multi-protocol)
│   │   ├── cisco_sdk.dart                  ← Main SDK interface
│   │   ├── protocols/
│   │   │   ├── snmp/                       ← SNMP implementation
│   │   │   │   ├── cisco_snmp_client.dart
│   │   │   │   └── cisco_mibs.dart
│   │   │   ├── netconf/                    ← NETCONF implementation
│   │   │   │   └── cisco_netconf_client.dart
│   │   │   ├── restconf/                   ← RESTCONF implementation
│   │   │   │   └── cisco_restconf_client.dart
│   │   │   └── ssh/                        ← SSH/CLI implementation
│   │   │       └── cisco_cli_client.dart
│   │   ├── models/
│   │   │   ├── cisco_device.dart
│   │   │   ├── cisco_interface.dart
│   │   │   └── cisco_vlan.dart
│   │   └── utils/
│   │       └── cisco_parser.dart
│   │
│   └── snmp_vendor_extensions/              ← Vendor-specific SNMP extensions
│       ├── asterisk_mib.dart
│       ├── microsoft_mib.dart
│       └── esxi_mib.dart
│
├── modules/                                  ← Vendor-specific modules
│   │
│   ├── _shared/                             ← Shared utilities for all modules
│   │   ├── base_device_module.dart         ← Abstract base class
│   │   ├── device_dashboard_base.dart
│   │   └── widgets/
│   │       ├── metric_card.dart
│   │       ├── status_indicator.dart
│   │       ├── device_header.dart
│   │       └── connection_status_badge.dart
│   │
│   ├── mikrotik/                            ← MikroTik RouterOS (EXISTING)
│   │   ├── core/
│   │   │   └── mikrotik_module.dart        ← Module definition
│   │   ├── auth/                            ← Authentication
│   │   ├── dashboard/                       ← System resources
│   │   ├── firewall/                        ← Firewall rules
│   │   ├── hotspot/                         ← HotSpot management
│   │   ├── dhcp/                            ← DHCP server
│   │   ├── interfaces/                      ← Network interfaces
│   │   ├── ip_addresses/                    ← IP addressing
│   │   ├── wireless/                        ← Wireless
│   │   ├── certificates/                    ← Certificate management
│   │   ├── ip_services/                     ← IP services
│   │   ├── letsencrypt/                     ← Let's Encrypt
│   │   ├── cloud/                           ← Cloud backup
│   │   ├── queues/                          ← Queue management
│   │   ├── backup/                          ← Backup/restore
│   │   ├── logs/                            ← System logs
│   │   └── tools/                           ← Network tools
│   │
│   ├── snmp/                                ← SNMP Module (EXISTING - Independent)
│   │   ├── core/
│   │   │   └── snmp_module.dart            ← Module definition
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── snmp_data_source.dart   ← Uses core SNMP client
│   │   │   │   └── saved_snmp_device_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── general_device_info_model.dart
│   │   │   │   ├── asterisk_device_info_model.dart  ← Currently exists
│   │   │   │   └── saved_snmp_device_model.dart
│   │   │   └── repositories/
│   │   │       ├── snmp_repository_impl.dart
│   │   │       └── saved_snmp_device_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── saved_snmp_device.dart
│   │   │   │   └── device_vendor.dart      ← Enum: general, cisco, asterisk, etc.
│   │   │   ├── repositories/
│   │   │   │   ├── snmp_repository.dart
│   │   │   │   └── saved_snmp_device_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_device_info_usecase.dart
│   │   │       ├── get_asterisk_device_info_usecase.dart
│   │   │       ├── save_device_usecase.dart
│   │   │       └── delete_device_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── snmp_monitor_bloc.dart
│   │       │   └── saved_snmp_device_bloc.dart
│   │       ├── pages/
│   │       │   └── snmp_dashboard_page.dart
│   │       └── widgets/
│   │           ├── general_device_info_widget.dart
│   │           └── asterisk_device_info_widget.dart
│   │
│   ├── cisco/                               ← Cisco Module (FUTURE)
│   │   ├── core/
│   │   │   └── cisco_module.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── cisco_snmp_datasource.dart     ← Uses sdks/cisco/
│   │   │   │   ├── cisco_netconf_datasource.dart  ← Uses sdks/cisco/
│   │   │   │   └── cisco_ssh_datasource.dart      ← Uses sdks/cisco/
│   │   │   ├── models/
│   │   │   │   ├── cisco_device_info.dart
│   │   │   │   ├── cisco_interface_model.dart
│   │   │   │   └── cisco_vlan_model.dart
│   │   │   └── repositories/
│   │   │       └── cisco_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── cisco_device.dart
│   │   │   ├── repositories/
│   │   │   │   └── cisco_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_cisco_device_info.dart
│   │   │       ├── get_interfaces.dart
│   │   │       ├── get_vlans.dart
│   │   │       └── get_routing_table.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── cisco_bloc.dart
│   │       │   ├── cisco_event.dart
│   │       │   └── cisco_state.dart
│   │       └── pages/
│   │           ├── cisco_dashboard_page.dart
│   │           ├── cisco_interfaces_page.dart
│   │           ├── cisco_vlans_page.dart
│   │           └── cisco_routing_page.dart
│   │
│   ├── asterisk/                            ← Asterisk PBX (FUTURE)
│   │   ├── core/
│   │   │   └── asterisk_module.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── asterisk_snmp_datasource.dart  ← Uses sdks/snmp_vendor_extensions/
│   │   │   │   └── asterisk_ami_datasource.dart   ← Asterisk Manager Interface
│   │   │   ├── models/
│   │   │   │   ├── asterisk_device_info.dart      ← Move from snmp/
│   │   │   │   ├── asterisk_channel.dart
│   │   │   │   └── asterisk_extension.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │       ├── get_asterisk_device_info.dart  ← Move from snmp/
│   │   │       ├── get_channels.dart
│   │   │       └── get_call_statistics.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │           ├── asterisk_dashboard_page.dart
│   │           ├── active_channels_page.dart
│   │           └── call_stats_page.dart
│   │
│   ├── microsoft/                           ← Windows Server (FUTURE)
│   │   ├── core/
│   │   │   └── microsoft_module.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── microsoft_snmp_datasource.dart
│   │   │   │   └── microsoft_wmi_datasource.dart  ← WMI protocol
│   │   │   ├── models/
│   │   │   │   ├── windows_server_info.dart
│   │   │   │   └── iis_info.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │       ├── get_server_info.dart
│   │   │       └── get_iis_sites.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │           └── microsoft_dashboard_page.dart
│   │
│   └── esxi/                                ← VMware ESXi (FUTURE)
│       ├── core/
│       │   └── esxi_module.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── esxi_snmp_datasource.dart
│       │   │   └── esxi_api_datasource.dart       ← vSphere API
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           └── pages/
│
└── features/                                 ← Cross-cutting features
    ├── app_auth/                            ← App-level authentication
    ├── home/                                ← Home page with module list
    │   ├── domain/
    │   │   └── entities/
    │   │       └── app_module.dart          ← Module interface
    │   └── presentation/
    ├── settings/                            ← App settings
    ├── subscription/                        ← In-app purchases
    └── about/                               ← About page
```

---

## 🏗️ Implementation Plan

### Phase 1: Foundation & SDK Layer (Day 1-2)

#### 1.1 Create Core Protocol Infrastructure
```bash
# Create directories
mkdir -p lib/core/protocols/snmp/models
mkdir -p lib/sdks/cisco/protocols/{snmp,netconf,restconf,ssh}
mkdir -p lib/sdks/snmp_vendor_extensions
mkdir -p lib/modules/_shared/widgets
```

**Files to create:**
- `lib/core/protocols/snmp/snmp_client.dart` - Base SNMP client (protocol level)
- `lib/core/protocols/snmp/snmp_session.dart` - SNMP session management
- `lib/core/protocols/snmp/models/` - Common SNMP models

#### 1.2 Create SDK Structure

**Cisco SDK** (for future use):
```dart
// lib/sdks/cisco/cisco_sdk.dart
class CiscoSDK {
  final CiscoSNMPClient snmpClient;
  final CiscoNetconfClient? netconfClient;
  final CiscoRestconfClient? restconfClient;
  final CiscoCLIClient? sshClient;
  
  CiscoSDK({
    required this.snmpClient,
    this.netconfClient,
    this.restconfClient,
    this.sshClient,
  });
  
  // Unified interface for multiple protocols
  Future<CiscoDeviceInfo> getDeviceInfo() async {
    // Try protocols in priority order
    if (netconfClient != null) {
      return await netconfClient!.getDeviceInfo();
    }
    return await snmpClient.getDeviceInfo();
  }
}
```

**SNMP Vendor Extensions**:
```dart
// lib/sdks/snmp_vendor_extensions/asterisk_mib.dart
class AsteriskMIB {
  static const String asteriskVersionOID = '1.3.6.1.4.1.22736.1.1.1.0';
  static const String asteriskConfigReloadTimeOID = '1.3.6.1.4.1.22736.1.1.3.0';
  // ... Asterisk-specific OIDs
}
```

#### 1.3 Define Module Interface
```dart
// lib/modules/_shared/base_device_module.dart
abstract class BaseDeviceModule {
  String get moduleName;
  String get moduleId;
  IconData get moduleIcon;
  Color get moduleColor;
  String get description;
  bool get isEnabled;  // Can be disabled in settings
  
  Widget buildDashboard(BuildContext context);
  Future<void> registerDependencies();
  Future<void> initialize();
  Future<void> dispose();
}
```

#### 1.4 Create Documentation Structure
```bash
# Create module documentation
docs/modules/mikrotik/README.md
docs/modules/snmp/README.md
docs/modules/cisco/README.md
docs/modules/asterisk/README.md
docs/modules/microsoft/README.md
docs/modules/esxi/README.md
docs/architecture/MODULE_GUIDELINES.md
docs/architecture/SDK_DEVELOPMENT.md
```

---

### Phase 2: Refactor SNMP Module (Day 2-3)

#### Current State Analysis:
- ✅ SNMP already exists as independent module
- ✅ Has General device support
- ✅ Has Asterisk-specific implementation
- ⚠️ Needs separation: General vs Vendor-specific

#### 2.1 Keep SNMP Core Structure
```
modules/snmp/  (NO CHANGES to folder structure)
  ├── core/snmp_module.dart
  ├── data/
  ├── domain/
  └── presentation/
```

#### 2.2 Document Current SNMP Implementation
```markdown
# docs/modules/snmp/README.md

## SNMP Module

### Overview
General-purpose SNMP monitoring module supporting:
- Generic SNMP v1/v2c/v3 devices
- Vendor-specific extensions (Asterisk currently implemented)

### Supported Vendors
- **General**: Any SNMP-enabled device
- **Asterisk**: PBX-specific metrics (via Asterisk MIB)

### Architecture
Uses `core/protocols/snmp/` for base protocol implementation.
Vendor extensions in `sdks/snmp_vendor_extensions/`.

### Usage
```dart
final device = SavedSnmpDevice(
  name: 'Issabel PBX',
  host: '192.168.85.88',
  port: 161,
  community: 'public',
  proprietary: DeviceVendor.asterisk,
);
```
```

#### 2.3 No Code Migration Needed
Since SNMP is already independent, only documentation and minor refactoring needed.

**Actions:**
- ✅ Keep current SNMP folder structure
- ✅ Document architecture in `docs/modules/snmp/`
- ✅ Move protocol-level code to `core/protocols/snmp/` if needed
- ✅ Keep Asterisk support within SNMP module (for now)

---

### Phase 3: Prepare for Future Modules (Day 3-4)

#### 3.1 Create MikroTik Module Wrapper
```bash
mkdir -p lib/modules/mikrotik/core
```

```dart
// lib/modules/mikrotik/core/mikrotik_module.dart
class MikroTikModule extends BaseDeviceModule {
  @override
  String get moduleName => 'MikroTik Assist';
  
  @override
  String get moduleId => 'mikrotik';
  
  @override
  IconData get moduleIcon => Icons.router;
  
  @override
  Color get moduleColor => Colors.blue;
  
  @override
  String get description => 'Complete RouterOS management suite';
  
  @override
  bool get isEnabled => true;
  
  @override
  Widget buildDashboard(BuildContext context) {
    return const DashboardPage();  // Existing dashboard
  }
  
  @override
  Future<void> registerDependencies() async {
    // Dependencies already registered in injection_container.dart
    // No changes needed
  }
}
```

#### 3.2 Create SNMP Module Wrapper
```dart
// lib/modules/snmp/core/snmp_module.dart
class SNMPModule extends BaseDeviceModule {
  @override
  String get moduleName => 'SNMP Assist';
  
  @override
  String get moduleId => 'snmp';
  
  @override
  IconData get moduleIcon => Icons.devices;
  
  @override
  Color get moduleColor => Colors.green;
  
  @override
  String get description => 'Monitor any SNMP-enabled device';
  
  @override
  bool get isEnabled => true;
  
  @override
  Widget buildDashboard(BuildContext context) {
    return const SnmpDashboardPage();  // Existing page
  }
  
  @override
  Future<void> registerDependencies() async {
    // Dependencies already registered
  }
}
```

#### 3.3 Document MikroTik Module
```markdown
# docs/modules/mikrotik/README.md

## MikroTik Assist Module

### Overview
Complete RouterOS management application with 13+ features.

### Features
1. **Dashboard** - System resources monitoring
2. **Firewall** - Rule management
3. **HotSpot** - User management, profiles, billing
4. **DHCP** - Server configuration
5. **Interfaces** - Network interface management
6. **IP Addresses** - IP address management
7. **Wireless** - WiFi configuration
8. **Certificates** - SSL/TLS certificate management
9. **IP Services** - Service configuration
10. **Let's Encrypt** - Automated certificates
11. **Cloud** - RouterOS Cloud backup
12. **Queues** - Traffic shaping
13. **Backup** - Configuration backup/restore
14. **Logs** - System logs viewer
15. **Tools** - Ping, Traceroute, DNS lookup

### Protocol
Uses proprietary RouterOS API via `core/network/routeros_client_v2.dart`.

### Authentication
Router-level authentication managed by `features/auth/`.
```

---

### Phase 4: Create Cisco SDK Foundation (Day 4-5)

#### 4.1 Create Cisco SDK Structure (For Future Use)
```bash
mkdir -p lib/sdks/cisco/protocols/{snmp,netconf,restconf,ssh}
mkdir -p lib/sdks/cisco/models
mkdir -p lib/sdks/cisco/utils
```

**Purpose**: When Cisco module is added, this SDK will provide:
- Multiple protocol support (SNMP, NETCONF, RESTCONF, SSH/CLI)
- Unified device management interface
- Reusable across different Cisco products (IOS, IOS-XE, NX-OS, etc.)

#### 4.2 Cisco SDK Interface
```dart
// lib/sdks/cisco/cisco_sdk.dart
/// Cisco SDK supporting multiple management protocols
class CiscoSDK {
  final String host;
  final int port;
  final String username;
  final String password;
  
  late CiscoSNMPClient? _snmpClient;
  late CiscoNetconfClient? _netconfClient;
  late CiscoRestconfClient? _restconfClient;
  late CiscoCLIClient? _cliClient;
  
  CiscoSDK({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });
  
  /// Initialize available protocols
  Future<void> init() async {
    // Detect which protocols are available
    _snmpClient = await _initSNMP();
    _netconfClient = await _initNetconf();
    _restconfClient = await _initRestconf();
    _cliClient = await _initCLI();
  }
  
  /// Get device information using best available protocol
  Future<CiscoDeviceInfo> getDeviceInfo() async {
    // Priority: NETCONF > RESTCONF > SNMP > CLI
    if (_netconfClient != null) {
      return await _netconfClient!.getDeviceInfo();
    } else if (_restconfClient != null) {
      return await _restconfClient!.getDeviceInfo();
    } else if (_snmpClient != null) {
      return await _snmpClient!.getDeviceInfo();
    } else if (_cliClient != null) {
      return await _cliClient!.getDeviceInfo();
    }
    throw Exception('No available protocols');
  }
  
  /// Get interfaces using best available protocol
  Future<List<CiscoInterface>> getInterfaces() async {
    // Implementation
  }
}
```

#### 4.3 Document Cisco SDK
```markdown
# docs/modules/cisco/SDK.md

## Cisco SDK

### Overview
Multi-protocol SDK for Cisco device management.

### Supported Protocols
1. **SNMP** - Basic monitoring (v1/v2c/v3)
2. **NETCONF** - Modern XML-based API (Yang models)
3. **RESTCONF** - RESTful API over HTTPS
4. **SSH/CLI** - Command-line interface automation

### Protocol Selection Strategy
SDK automatically selects best available protocol:
1. NETCONF (fastest, most reliable)
2. RESTCONF (HTTP-based, firewall-friendly)
3. SNMP (widest compatibility)
4. SSH/CLI (fallback for older devices)

### Usage Example
```dart
final sdk = CiscoSDK(
  host: '192.168.1.1',
  port: 22,
  username: 'admin',
  password: 'secret',
);

await sdk.init();
final deviceInfo = await sdk.getDeviceInfo();
final interfaces = await sdk.getInterfaces();
```

### Supported Devices
- Cisco IOS (15.x+)
- Cisco IOS-XE (16.x+)
- Cisco NX-OS
- Cisco IOS-XR
- Cisco ASA (limited)

```
---

### Phase 5: Update Module Registration (Day 5-6)

**5.1 Update Module Registry**
```dart
// lib/injection_container.dart

Future<void> initModules() async {
  // Register available modules
  final modules = <BaseDeviceModule>[
    MikroTikModule(),
    SNMPModule(),
    // Future modules (disabled for now):
    // CiscoModule(),
    // AsteriskModule(),  // Will replace SNMP Asterisk support
    // MicrosoftModule(),
    // ESXiModule(),
  ];
  
  // Register each module
  for (var module in modules) {
    await module.registerDependencies();
    await module.initialize();
  }
  
  // Register module list for home page
  sl.registerSingleton<List<BaseDeviceModule>>(
    modules.where((m) => m.isEnabled).toList(),
  );
}
```

**5.2 Update Home Page**
```dart
// lib/features/home/presentation/pages/home_page.dart

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get modules from DI (already filtered by isEnabled)
    final modules = sl<List<BaseDeviceModule>>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [...],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(l10n.welcomeToNetworkAssistant, ...),
              Expanded(
                child: GridView.builder(
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return ModuleTile(
                      name: module.moduleName,
                      icon: module.moduleIcon,
                      color: module.moduleColor,
                      description: module.description,
                      onTap: () => _navigateToModule(context, module),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToModule(BuildContext context, BaseDeviceModule module) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => module.buildDashboard(context),
      ),
    );
  }
}
```

---

### Phase 6: Documentation & Cleanup (Day 6)

**6.1 Create Architecture Documentation**
```markdown
# docs/architecture/MODULE_GUIDELINES.md

## Module Development Guidelines

### Creating a New Module

1. **Create module structure**:
```bash
mkdir -p lib/modules/my_module/{core,data,domain,presentation}
```

2. **Implement BaseDeviceModule**:
```dart
class MyModule extends BaseDeviceModule {
  @override
  String get moduleName => 'My Device';
  // ... implement all required methods
}
```

3. **Register in injection_container.dart**:
```dart
final modules = [
  // ...
  MyModule(),
];
```

4. **Create documentation**:
```bash
docs/modules/my_module/README.md
```

### Module Checklist
- [ ] Implements BaseDeviceModule interface
- [ ] Has core/MODULE_NAME_module.dart
- [ ] Has proper dependency injection
- [ ] Has documentation in docs/modules/
- [ ] Has unit tests
- [ ] Has integration tests
- [ ] Follows Clean Architecture
```

**6.2 Create SDK Development Guide**
```markdown
# docs/architecture/SDK_DEVELOPMENT.md

## SDK Development Guide

### When to Create an SDK?

Create SDK when:
1. Multiple protocols needed (e.g., Cisco: SNMP + NETCONF + SSH)
2. Multiple modules will use same functionality
3. Complex vendor-specific logic
4. Third-party API integration

### SDK Structure
```
lib/sdks/vendor_name/
├── vendor_sdk.dart          ← Main SDK interface
├── protocols/               ← Protocol implementations
│   ├── protocol1/
│   └── protocol2/
├── models/                  ← Data models
└── utils/                   ← Helper utilities
```

### Example: Multi-Protocol SDK
```dart
class VendorSDK {
  final Protocol1Client? protocol1;
  final Protocol2Client? protocol2;
  
  // Unified interface
  Future<DeviceInfo> getDeviceInfo();
  Future<List<Interface>> getInterfaces();
}
```
```

**6.3 Update Project README**
```markdown
# Network Assistant

Multi-vendor network device management application.

## Modules

### Available Now
- **MikroTik Assist**: Complete RouterOS management (13+ features)
- **SNMP Assist**: General SNMP device monitoring + Asterisk support

### Coming Soon
- **Cisco Module**: Multi-protocol Cisco device management
- **Asterisk PBX**: Dedicated Asterisk management (migrated from SNMP)
- **Microsoft Server**: Windows Server monitoring
- **VMware ESXi**: VMware hypervisor management

## Documentation

See `docs/` folder:
- `docs/architecture/` - Architecture guidelines
- `docs/modules/` - Per-module documentation

## Development

### Adding a New Module
1. Read `docs/architecture/MODULE_GUIDELINES.md`
2. Create module structure under `lib/modules/`
3. Implement `BaseDeviceModule`
4. Register in `injection_container.dart`
5. Add documentation to `docs/modules/`
```

**6.4 Final Testing**
- [ ] Run full test suite: `flutter test`
- [ ] Test MikroTik module still works
- [ ] Test SNMP module still works
- [ ] Test module registration
- [ ] Test home page displays modules correctly
- [ ] Performance testing (no regression)
- [ ] Build APK: `flutter build apk`

---

## 🎨 Before & After Comparison

### Before (Current State)

**Structure:**
```
lib/features/
├── auth/, app_auth/, home/, settings/, subscription/
├── dashboard/  ← MikroTik feature
├── firewall/   ← MikroTik feature
├── hotspot/    ← MikroTik feature
├── dhcp/       ← MikroTik feature
├── ... (9 more MikroTik features)
└── snmp/       ← Independent module (GOOD!)
    └── Contains: General + Asterisk support
```

**Issues:**
- ❌ MikroTik features mixed with app features
- ❌ No clear module boundaries
- ❌ Difficult to add new vendors
- ❌ No SDK layer for shared functionality
- ❌ Documentation scattered

### After (Proposed State)

**Structure:**
```
lib/
├── core/              ← Core infrastructure
│   └── protocols/     ← Protocol implementations (SNMP, etc.)
├── sdks/              ← Reusable SDKs (Cisco, etc.)
├── modules/           ← Clear vendor modules
│   ├── mikrotik/      ← All MikroTik features
│   ├── snmp/          ← General SNMP (existing)
│   ├── cisco/         ← Future
│   ├── asterisk/      ← Future
│   ├── microsoft/     ← Future
│   └── esxi/          ← Future
└── features/          ← Cross-cutting features only

docs/modules/          ← Per-module documentation
```

**Benefits:**
- ✅ Clear module boundaries
- ✅ Easy to add new vendors (copy template)
- ✅ Shared SDKs reduce code duplication
- ✅ Organized documentation
- ✅ Better testability

---

## 📊 Impact Analysis

### Code Organization
| Aspect | Before | After | Improvement |
|--------|--------|-------|-------------|
| Module clarity | Mixed | Clear | ✅ 100% |
| Vendor separation | Partial | Complete | ✅ 100% |
| SDK reusability | None | Available | ✅ New capability |
| Documentation | Scattered | Organized | ✅ Centralized |

### Development Velocity
| Task | Before | After | Improvement |
|------|--------|-------|-------------|
| Add new vendor | 3-4 days | 1-2 days | ✅ 50% faster |
| Find vendor code | Search project | Go to module | ✅ Instant |
| Understand architecture | Study codebase | Read docs/architecture | ✅ Clear |
| Share code across modules | Copy-paste | Use SDK | ✅ DRY principle |

### Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking MikroTik features | Low | High | Thorough testing, gradual migration |
| Breaking SNMP module | Very Low | Medium | SNMP stays as-is, minimal changes |
| Developer confusion | Medium | Low | Clear documentation in docs/ |
| Increased complexity | Low | Low | Folder structure is actually simpler |

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// Test module interface
test('mikrotik_module_implements_base_interface', () {
  final module = MikroTikModule();
  expect(module, isA<BaseDeviceModule>());
  expect(module.moduleName, 'MikroTik Assist');
  expect(module.isEnabled, true);
});

// Test SNMP module
test('snmp_module_loads_correctly', () {
  final module = SNMPModule();
  expect(module.moduleId, 'snmp');
  expect(module.moduleName, 'SNMP Assist');
});
```

### Integration Tests
```dart
testWidgets('home_page_displays_all_enabled_modules', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Should show MikroTik and SNMP
  expect(find.text('MikroTik Assist'), findsOneWidget);
  expect(find.text('SNMP Assist'), findsOneWidget);
  
  // Should NOT show future modules (disabled)
  expect(find.text('Cisco'), findsNothing);
  expect(find.text('Asterisk PBX'), findsNothing);
});

testWidgets('module_navigation_works', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap MikroTik module
  await tester.tap(find.text('MikroTik Assist'));
  await tester.pumpAndSettle();
  
  // Should navigate to MikroTik dashboard
  expect(find.byType(DashboardPage), findsOneWidget);
});
```

### Manual Testing Checklist
- [ ] All existing MikroTik features work identically
- [ ] SNMP monitoring works (General + Asterisk)
- [ ] Home page shows only enabled modules
- [ ] Module navigation works correctly
- [ ] Authentication flows unchanged
- [ ] No performance degradation
- [ ] App builds successfully
- [ ] No new errors in console

---

## 💰 Cost-Benefit Analysis

### Immediate Costs (Time Investment)
- **Phase 1**: Foundation & SDK layer (1-2 days)
- **Phase 2**: SNMP documentation (0.5 day)
- **Phase 3**: Module wrappers (0.5 day)
- **Phase 4**: Cisco SDK preparation (1 day)
- **Phase 5**: Module registration (0.5 day)
- **Phase 6**: Documentation & testing (1 day)
- **Total**: 4-6 working days

### Long-term Benefits
- ✅ **50% faster** new vendor development
- ✅ **Reusable SDKs** reduce code duplication
- ✅ **Clear documentation** reduces onboarding time
- ✅ **Better architecture** = fewer bugs
- ✅ **Parallel development** possible

### Break-even Point
After adding **1 new vendor** (Cisco), time saved = time invested.

---

## 🚀 Next Steps

### Immediate Actions (If Approved)

1. **Create feature branch**:
```bash
git checkout -b refactor/modular-architecture
git tag pre-refactor  # Backup point
```

2. **Phase 1 Start**:
```bash
# Create directory structures
mkdir -p lib/core/protocols/snmp/models
mkdir -p lib/sdks/cisco/protocols/{snmp,netconf,restconf,ssh}
mkdir -p lib/sdks/snmp_vendor_extensions
mkdir -p lib/modules/_shared/widgets
mkdir -p lib/modules/mikrotik/core
mkdir -p lib/modules/snmp/core
```

3. **Create base files**:
```bash
touch lib/modules/_shared/base_device_module.dart
touch lib/modules/mikrotik/core/mikrotik_module.dart
touch lib/modules/snmp/core/snmp_module.dart
touch docs/architecture/MODULE_GUIDELINES.md
touch docs/architecture/SDK_DEVELOPMENT.md
```

### Phase Completion Criteria

**Phase 1**: ✅ Foundation complete
- [ ] All directories created
- [ ] BaseDeviceModule interface defined
- [ ] Core SNMP protocol separated
- [ ] Documentation structure in place

**Phase 2**: ✅ SNMP documented
- [ ] docs/modules/snmp/README.md created
- [ ] Current functionality documented
- [ ] No breaking changes

**Phase 3**: ✅ Module wrappers ready
- [ ] MikroTikModule created
- [ ] SNMPModule created
- [ ] Both implement BaseDeviceModule
- [ ] Tests pass

**Phase 4**: ✅ SDK foundation ready
- [ ] Cisco SDK structure created
- [ ] SDK interfaces documented
- [ ] Ready for implementation

**Phase 5**: ✅ Registration updated
- [ ] injection_container.dart updated
- [ ] Home page uses module registry
- [ ] All features work

**Phase 6**: ✅ Complete & documented
- [ ] All tests pass
- [ ] Documentation complete
- [ ] No regressions
- [ ] APK builds successfully

### Success Metrics
- ✅ Zero breaking changes to existing features
- ✅ All tests pass (unit + integration)
- ✅ Documentation coverage: 100%
- ✅ Code review approved
- ✅ Performance: no regression
- ✅ User experience: unchanged

---

## 📚 Additional Resources

### Architecture Patterns
- **Clean Architecture** by Uncle Bob - Separation of concerns
- **Modular Monolith** - Independent modules in single repository
- **Plugin Architecture** - Hot-swappable components

### Flutter Best Practices
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Very Good Architecture](https://verygood.ventures/blog/very-good-flutter-architecture)
- [Feature-First Organization](https://codewithandrea.com/articles/flutter-project-structure/)

### Documentation Tools
- [MkDocs](https://www.mkdocs.org/) - For generating documentation site
- [Mermaid](https://mermaid.js.org/) - For architecture diagrams
- [Docusaurus](https://docusaurus.io/) - Alternative documentation framework

---

## 📝 Appendix

### A. Module Template Checklist

When creating a new module, use this checklist:

```bash
# 1. Create structure
mkdir -p lib/modules/MODULE_NAME/{core,data,domain,presentation}
mkdir -p docs/modules/MODULE_NAME

# 2. Create core module file
touch lib/modules/MODULE_NAME/core/MODULE_NAME_module.dart

# 3. Create documentation
touch docs/modules/MODULE_NAME/README.md
touch docs/modules/MODULE_NAME/ARCHITECTURE.md
touch docs/modules/MODULE_NAME/API.md  # If has external API

# 4. Implement interface
# Edit MODULE_NAME_module.dart to implement BaseDeviceModule

# 5. Register module
# Add to injection_container.dart

# 6. Add tests
mkdir -p test/modules/MODULE_NAME
touch test/modules/MODULE_NAME/MODULE_NAME_module_test.dart
```

### B. Current vs Proposed File Mapping

| Current Location | Proposed Location | Action |
|------------------|-------------------|--------|
| `features/dashboard/` | `modules/mikrotik/dashboard/` | 📝 Plan (future) |
| `features/firewall/` | `modules/mikrotik/firewall/` | 📝 Plan (future) |
| `features/snmp/` | `modules/snmp/` | ✅ Keep as-is |
| `features/snmp/data/models/asterisk_*` | `modules/snmp/` (for now) | ✅ Keep |
| N/A | `modules/cisco/` | 🆕 Future |
| N/A | `modules/asterisk/` | 🆕 Future |
| N/A | `modules/microsoft/` | 🆕 Future |
| N/A | `sdks/cisco/` | 🆕 Future |

### C. SDK vs Module Decision Tree

```
Do you need multi-protocol support?
├─ Yes → Create SDK
│  ├─ Example: Cisco (SNMP + NETCONF + SSH)
│  └─ Location: lib/sdks/vendor_name/
│
└─ No → Create Module directly
   ├─ Example: MikroTik (proprietary API only)
   └─ Location: lib/modules/vendor_name/

Will this be used by multiple modules?
├─ Yes → Create SDK
│  ├─ Example: SNMP protocol (used by multiple vendors)
│  └─ Location: lib/core/protocols/ or lib/sdks/
│
└─ No → Keep in module
   └─ Location: lib/modules/vendor_name/
```

### D. Vendor-Specific Documentation Requirements

Each module should have:

1. **README.md** - Overview, features, setup
2. **ARCHITECTURE.md** - Technical architecture, data flow
3. **API.md** - External API documentation (if applicable)
4. **TROUBLESHOOTING.md** - Common issues and solutions
5. **CHANGELOG.md** - Version history

Example structure:
```
docs/modules/cisco/
├── README.md              ← Overview
├── ARCHITECTURE.md        ← Technical details
├── API.md                 ← NETCONF/RESTCONF APIs
├── TROUBLESHOOTING.md     ← Common issues
├── CHANGELOG.md           ← Version history
└── examples/              ← Code examples
    ├── basic_monitoring.md
    ├── vlan_configuration.md
    └── routing_setup.md
```

---

## ✅ Approval & Sign-off

**Proposal Created By:** GitHub Copilot  
**Date:** 2025-12-30  
**Revision:** 2.0 (Updated based on actual project state)  
**Status:** 🟡 Awaiting Review  

### Key Changes from v1.0:
- ✅ Recognized SNMP as independent module (not under MikroTik)
- ✅ Added SDK layer for multi-protocol support
- ✅ Created docs/ structure for organized documentation
- ✅ Clarified that Cisco, Microsoft, ESXi not yet implemented
- ✅ Reduced timeline (4-6 days instead of 5-7)
- ✅ Focus on documentation and structure (minimal code changes)

### Stakeholder Approvals:
- [ ] Lead Developer - Architecture review
- [ ] Product Owner - Priority and timeline
- [ ] DevOps - Build and deployment impact

### Review Checklist:
- [ ] Architecture makes sense for current state
- [ ] Timeline is realistic
- [ ] Documentation structure is clear
- [ ] SDK approach is beneficial
- [ ] No breaking changes to existing features
- [ ] Future vendors can be added easily

---

**Questions or concerns?** Let's discuss! 💬

**Ready to proceed?** Start with Phase 1 after approval.
