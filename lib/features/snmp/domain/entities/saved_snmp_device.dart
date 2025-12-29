import 'package:equatable/equatable.dart';

/// Enum representing different device vendors/types
enum DeviceVendor {
  general,
  cisco,
  asterisk,
  microsoft;

  String get displayName {
    switch (this) {
      case DeviceVendor.general:
        return 'General';
      case DeviceVendor.cisco:
        return 'Cisco';
      case DeviceVendor.asterisk:
        return 'Asterisk';
      case DeviceVendor.microsoft:
        return 'Microsoft';
    }
  }

  static DeviceVendor fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cisco':
        return DeviceVendor.cisco;
      case 'asterisk':
        return DeviceVendor.asterisk;
      case 'microsoft':
        return DeviceVendor.microsoft;
      case 'general':
      default:
        return DeviceVendor.general;
    }
  }
}

/// Entity representing a saved SNMP device configuration
class SavedSnmpDevice extends Equatable {
  final int? id;
  final String name;
  final String host;
  final int port;
  final String community;
  final DeviceVendor proprietary;
  final bool isDefault;
  final DateTime? lastConnected;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedSnmpDevice({
    this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.community,
    this.proprietary = DeviceVendor.general,
    this.isDefault = false,
    this.lastConnected,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new SavedSnmpDevice with current timestamp
  factory SavedSnmpDevice.create({
    required String name,
    required String host,
    required int port,
    required String community,
    DeviceVendor proprietary = DeviceVendor.general,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return SavedSnmpDevice(
      name: name,
      host: host,
      port: port,
      community: community,
      proprietary: proprietary,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  SavedSnmpDevice copyWith({
    int? id,
    String? name,
    String? host,
    int? port,
    String? community,
    DeviceVendor? proprietary,
    bool? isDefault,
    DateTime? lastConnected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedSnmpDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      community: community ?? this.community,
      proprietary: proprietary ?? this.proprietary,
      isDefault: isDefault ?? this.isDefault,
      lastConnected: lastConnected ?? this.lastConnected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        host,
        port,
        community,
        proprietary,
        isDefault,
        lastConnected,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'SavedSnmpDevice(id: $id, name: $name, host: $host:$port, community: $community, proprietary: ${proprietary.name}, isDefault: $isDefault)';
  }
}
