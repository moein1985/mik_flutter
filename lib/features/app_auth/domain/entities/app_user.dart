import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String username;
  final String passwordHash;
  final bool biometricEnabled;
  final DateTime createdAt;
  final bool isDefault;

  const AppUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.biometricEnabled = false,
    required this.createdAt,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, username, passwordHash, biometricEnabled, createdAt, isDefault];

  AppUser copyWith({
    String? id,
    String? username,
    String? passwordHash,
    bool? biometricEnabled,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
