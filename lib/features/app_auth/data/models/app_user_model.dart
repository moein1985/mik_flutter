import 'package:hive/hive.dart';
import '../../domain/entities/app_user.dart';

part 'app_user_model.g.dart';

@HiveType(typeId: 0)
class AppUserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String passwordHash;

  @HiveField(3)
  bool biometricEnabled;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isDefault;

  AppUserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.biometricEnabled = false,
    required this.createdAt,
    this.isDefault = false,
  });

  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(
      id: user.id,
      username: user.username,
      passwordHash: user.passwordHash,
      biometricEnabled: user.biometricEnabled,
      createdAt: user.createdAt,
      isDefault: user.isDefault,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      username: username,
      passwordHash: passwordHash,
      biometricEnabled: biometricEnabled,
      createdAt: createdAt,
      isDefault: isDefault,
    );
  }
}
