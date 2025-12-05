import 'package:equatable/equatable.dart';

/// Entity representing a saved router configuration
class SavedRouter extends Equatable {
  final int? id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useSsl;
  final bool isDefault;
  final DateTime? lastConnected;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedRouter({
    this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.useSsl = false,
    this.isDefault = false,
    this.lastConnected,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new SavedRouter with current timestamp
  factory SavedRouter.create({
    required String name,
    required String host,
    required int port,
    required String username,
    required String password,
    bool useSsl = false,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return SavedRouter(
      name: name,
      host: host,
      port: port,
      username: username,
      password: password,
      useSsl: useSsl,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  SavedRouter copyWith({
    int? id,
    String? name,
    String? host,
    int? port,
    String? username,
    String? password,
    bool? useSsl,
    bool? isDefault,
    DateTime? lastConnected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedRouter(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      useSsl: useSsl ?? this.useSsl,
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
        username,
        password,
        useSsl,
        isDefault,
        lastConnected,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'SavedRouter(id: $id, name: $name, host: $host:$port, username: $username, useSsl: $useSsl, isDefault: $isDefault)';
  }
}
