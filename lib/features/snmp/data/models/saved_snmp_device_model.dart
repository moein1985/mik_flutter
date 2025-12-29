import '../../domain/entities/saved_snmp_device.dart';

/// Data model for SavedSnmpDevice with database serialization
class SavedSnmpDeviceModel extends SavedSnmpDevice {
  const SavedSnmpDeviceModel({
    super.id,
    required super.name,
    required super.host,
    required super.port,
    required super.community,
    super.proprietary,
    super.isDefault,
    super.lastConnected,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from database map
  factory SavedSnmpDeviceModel.fromMap(Map<String, dynamic> map) {
    return SavedSnmpDeviceModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      host: map['host'] as String,
      port: map['port'] as int,
      community: map['community'] as String,
      proprietary: DeviceVendor.fromString(map['proprietary'] as String),
      isDefault: (map['is_default'] as int) == 1,
      lastConnected: map['last_connected'] != null
          ? DateTime.parse(map['last_connected'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create from entity
  factory SavedSnmpDeviceModel.fromEntity(SavedSnmpDevice device) {
    return SavedSnmpDeviceModel(
      id: device.id,
      name: device.name,
      host: device.host,
      port: device.port,
      community: device.community,
      proprietary: device.proprietary,
      isDefault: device.isDefault,
      lastConnected: device.lastConnected,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'host': host,
      'port': port,
      'community': community,
      'proprietary': proprietary.name,
      'is_default': isDefault ? 1 : 0,
      'last_connected': lastConnected?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to map for insert (without id)
  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'host': host,
      'port': port,
      'community': community,
      'proprietary': proprietary.name,
      'is_default': isDefault ? 1 : 0,
      'last_connected': lastConnected?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
