# MikroTik Assist Module

## Overview
Complete RouterOS management application with 13+ feature modules for comprehensive MikroTik router administration.

## Features

### Core Management
1. **Dashboard** - System resources monitoring (CPU, Memory, Storage, Uptime)
2. **Interfaces** - Network interface management and monitoring
3. **IP Addresses** - IP address assignment and management
4. **Firewall** - Firewall rule management and configuration
5. **DHCP** - DHCP server configuration and lease management

### Network Services
6. **HotSpot** - Captive portal management
   - User management
   - Active sessions
   - Profiles and billing
   - IP bindings
   - Walled garden
7. **Wireless** - WiFi configuration and monitoring
8. **Queues** - Traffic shaping and QoS

### Security & Certificates
9. **Certificates** - SSL/TLS certificate management
10. **Let's Encrypt** - Automated certificate provisioning

### Advanced Features
11. **IP Services** - RouterOS service configuration
12. **Cloud** - RouterOS Cloud backup integration
13. **Backup** - Configuration backup and restore
14. **Logs** - System logs viewer
15. **Tools** - Network diagnostic tools (Ping, Traceroute, DNS lookup)

## Protocol
Uses proprietary RouterOS API via `core/network/routeros_client_v2.dart`.

**Connection:**
- Protocol: RouterOS API
- Default Port: 8728 (non-SSL) / 8729 (SSL)
- Authentication: Username/Password

## Authentication
Router-level authentication managed by `features/auth/` module.

**Flow:**
1. App-level authentication (AppAuthBloc)
2. Router selection/login (AuthBloc)
3. Access to dashboard and features

## Module Structure
```
modules/mikrotik/
├── core/
│   └── mikrotik_module.dart     ← Module definition
├── auth/                         ← Router authentication
├── dashboard/                    ← System resources
├── firewall/                     ← Firewall management
├── hotspot/                      ← HotSpot features
├── dhcp/                         ← DHCP server
├── interfaces/                   ← Interface management
├── wireless/                     ← WiFi configuration
├── certificates/                 ← Certificate management
├── ip_services/                  ← IP services
├── letsencrypt/                  ← Let's Encrypt
├── cloud/                        ← Cloud backup
├── queues/                       ← Queue management
├── backup/                       ← Backup/restore
├── logs/                         ← System logs
└── tools/                        ← Network tools
```

## Dependencies
- `get_it` - Dependency injection
- `flutter_bloc` - State management
- `go_router` - Navigation
- `hive` - Local storage

## Usage Example
```dart
// Navigate to MikroTik dashboard
context.push(AppRoutes.mikrotik);

// Or use module interface
final module = MikroTikModule();
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => module.buildDashboard(context),
  ),
);
```

## Future Enhancements
- [ ] Graphical bandwidth monitoring
- [ ] Configuration templates
- [ ] Batch operations
- [ ] Real-time monitoring with WebSocket
- [ ] Multi-router management
- [ ] Script execution

## Support
- **RouterOS Version**: 6.x, 7.x
- **Architectures**: ARM, ARM64, x86, x86-64, MIPS, PowerPC
- **Tested Devices**: RB750, RB4011, CCR series, hEX series

## Troubleshooting
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

## Contributing
See [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.
