# SNMP Assist Module

## Overview
General-purpose SNMP monitoring module for managing any SNMP-enabled network device. Supports standard SNMP v1/v2c/v3 protocols with vendor-specific extensions.

## Supported Vendors

### General (Standard SNMP)
Monitor any SNMP-enabled device using standard MIB-II OIDs:
- System information (sysName, sysDescr, sysUpTime, etc.)
- Network interfaces
- IP addresses
- Routing tables
- CPU and memory usage (if available)

### Asterisk PBX (Vendor-Specific)
Enhanced monitoring for Asterisk-based PBX systems:
- Asterisk version and configuration
- Active channels by type (SIP, PJSIP, IAX2, etc.)
- Call statistics
- Extension states
- Trunk status

**Supported Asterisk Versions:**
- Asterisk 13+
- Asterisk 16+
- Asterisk 18+ (tested on Issabel 5)

**Requirements:**
- Asterisk SNMP agent enabled
- ASTERISK-MIB loaded
- Community string configured

## Protocol Details

### SNMP Versions Supported
- **SNMP v1**: Basic monitoring, community-based authentication
- **SNMP v2c**: Enhanced error handling, community-based
- **SNMP v3**: Secure authentication and encryption (future)

### Connection Parameters
- **Host**: Device IP address
- **Port**: 161 (default SNMP port)
- **Community**: Read-only community string (default: "public")
- **Timeout**: 5 seconds
- **Retries**: 3

## Module Structure
```
modules/snmp/
├── core/
│   └── snmp_module.dart                    ← Module definition
├── data/
│   ├── datasources/
│   │   ├── snmp_data_source.dart          ← SNMP client wrapper
│   │   └── saved_snmp_device_local_data_source.dart
│   ├── models/
│   │   ├── general_device_info_model.dart ← General SNMP
│   │   ├── asterisk_device_info_model.dart← Asterisk-specific
│   │   └── saved_snmp_device_model.dart
│   └── repositories/
│       ├── snmp_repository_impl.dart
│       └── saved_snmp_device_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── saved_snmp_device.dart
│   │   └── device_vendor.dart             ← Enum: general, asterisk, cisco, etc.
│   ├── repositories/
│   │   ├── snmp_repository.dart
│   │   └── saved_snmp_device_repository.dart
│   └── usecases/
│       ├── get_device_info_usecase.dart
│       ├── get_asterisk_device_info_usecase.dart
│       ├── save_device_usecase.dart
│       ├── delete_device_usecase.dart
│       └── set_default_device_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── snmp_monitor_bloc.dart
    │   └── saved_snmp_device_bloc.dart
    ├── pages/
    │   └── snmp_dashboard_page.dart
    └── widgets/
        ├── general_device_info_widget.dart
        └── asterisk_device_info_widget.dart
```

## Core Protocol Layer
SNMP protocol implementation is separated into:
```
core/protocols/snmp/
├── snmp_client.dart         ← Base SNMP client
├── snmp_session.dart        ← Session management
└── models/
    ├── snmp_device.dart
    ├── snmp_metric.dart
    └── snmp_oid.dart
```

## Vendor Extensions
Vendor-specific MIB definitions:
```
sdks/snmp_vendor_extensions/
├── asterisk_mib.dart        ← ASTERISK-MIB OIDs
├── cisco_mib.dart           ← Future: Cisco MIBs
└── microsoft_mib.dart       ← Future: Windows MIBs
```

## Usage Example

### Monitor General Device
```dart
final device = SavedSnmpDevice(
  name: 'Core Switch',
  host: '192.168.1.1',
  port: 161,
  community: 'public',
  proprietary: DeviceVendor.general,  // Standard SNMP
);

context.read<SnmpMonitorBloc>().add(
  MonitorDeviceRequested(
    ip: device.host,
    community: device.community,
    port: device.port,
    vendor: device.proprietary,
  ),
);
```

### Monitor Asterisk PBX
```dart
final asterisk = SavedSnmpDevice(
  name: 'Issabel PBX',
  host: '192.168.85.88',
  port: 161,
  community: 'public',
  proprietary: DeviceVendor.asterisk,  // Asterisk-specific
);

// Will fetch both general and Asterisk-specific metrics
context.read<SnmpMonitorBloc>().add(
  MonitorDeviceRequested(
    ip: asterisk.host,
    community: asterisk.community,
    port: asterisk.port,
    vendor: asterisk.proprietary,
  ),
);
```

## Device Management

### Save Device
```dart
final useCase = sl<SaveDeviceUseCase>();
await useCase(device);
```

### Load Saved Devices
```dart
context.read<SavedSnmpDeviceBloc>().add(LoadSavedDevicesRequested());
```

### Set Default Device
```dart
context.read<SavedSnmpDeviceBloc>().add(
  SetDefaultDeviceRequested(deviceId: device.id!),
);
```

## Configuration

### Enable SNMP on Asterisk
```bash
# /etc/asterisk/manager.conf
[general]
enabled = yes
webenabled = yes

# Enable SNMP agent
sudo systemctl enable snmpd
sudo systemctl start snmpd

# Load Asterisk MIB
# Add to /etc/snmp/snmpd.conf:
master agentx
agentXSocket /var/run/agentx/master
```

## Limitations

### Current Limitations
- SNMP v3 not yet implemented
- No trap/inform support
- Read-only operations only
- No bulk operations
- Limited MIB browser functionality

### Asterisk Limitations (Issabel 5)
- ❌ PJSIP endpoint monitoring (OIDs not implemented in Issabel 5)
- ❌ SIP peer details (OIDs not implemented in Issabel 5)
- ✅ Channel types and counts (working)
- ✅ Version and configuration (working)
- ✅ Call statistics (working)

## Future Enhancements
- [ ] SNMP v3 support
- [ ] SNMP trap receiver
- [ ] MIB browser
- [ ] Graphical monitoring
- [ ] Alert thresholds
- [ ] Historical data collection
- [ ] More vendor-specific extensions (Cisco, Microsoft, ESXi)

## Troubleshooting

### Common Issues

**1. Connection Timeout**
- Verify device IP and port
- Check firewall rules (UDP port 161)
- Verify SNMP agent is running on device
- Test with snmpwalk: `snmpwalk -v2c -c public 192.168.1.1`

**2. Authentication Failed**
- Verify community string
- Check SNMP agent configuration
- Ensure community has read access

**3. No Data Returned**
- Verify OIDs are supported by device
- Check MIB availability
- Use vendor-specific OIDs if needed

**4. Asterisk-Specific Issues**
- Verify ASTERISK-MIB is loaded
- Check Asterisk SNMP agent: `asterisk -rx 'manager show settings'`
- Verify SNMP subagent is running

## Dependencies
- `dart_snmp` - SNMP protocol implementation
- `hive` - Local storage for saved devices
- `flutter_bloc` - State management
- `get_it` - Dependency injection

## Contributing
When adding support for new vendors:
1. Create MIB definition in `sdks/snmp_vendor_extensions/`
2. Add vendor to `DeviceVendor` enum
3. Create use case for vendor-specific data
4. Update UI to display vendor metrics

## References
- [RFC 1157](https://www.rfc-editor.org/rfc/rfc1157) - SNMP v1
- [RFC 3416](https://www.rfc-editor.org/rfc/rfc3416) - SNMP v2c
- [ASTERISK-MIB](https://github.com/asterisk/asterisk/blob/master/doc/ASTERISK-MIB.txt)
- [MIB-II](https://www.rfc-editor.org/rfc/rfc1213) - Standard MIB
