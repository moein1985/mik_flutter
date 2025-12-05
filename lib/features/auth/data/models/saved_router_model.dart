import '../../domain/entities/saved_router.dart';

/// Data model for SavedRouter with database serialization
class SavedRouterModel extends SavedRouter {
  const SavedRouterModel({
    super.id,
    required super.name,
    required super.host,
    required super.port,
    required super.username,
    required super.password,
    super.useSsl,
    super.isDefault,
    super.lastConnected,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from database map
  factory SavedRouterModel.fromMap(Map<String, dynamic> map) {
    return SavedRouterModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      host: map['host'] as String,
      port: map['port'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      useSsl: (map['use_ssl'] as int?) == 1,
      isDefault: (map['is_default'] as int) == 1,
      lastConnected: map['last_connected'] != null
          ? DateTime.parse(map['last_connected'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create from entity
  factory SavedRouterModel.fromEntity(SavedRouter router) {
    return SavedRouterModel(
      id: router.id,
      name: router.name,
      host: router.host,
      port: router.port,
      username: router.username,
      password: router.password,
      useSsl: router.useSsl,
      isDefault: router.isDefault,
      lastConnected: router.lastConnected,
      createdAt: router.createdAt,
      updatedAt: router.updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'use_ssl': useSsl ? 1 : 0,
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
      'username': username,
      'password': password,
      'use_ssl': useSsl ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
      'last_connected': lastConnected?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
