import '../../domain/entities/security_profile.dart';

class SecurityProfileModel extends SecurityProfile {
  const SecurityProfileModel({
    required super.id,
    required super.name,
    required super.authentication,
    required super.encryption,
    required super.password,
    required super.mode,
    required super.managementProtection,
    required super.wpaPreSharedKey,
    required super.wpa2PreSharedKey,
  });

  factory SecurityProfileModel.fromMap(Map<String, dynamic> map) {
    return SecurityProfileModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      authentication: map['authentication-types'] ?? '',
      encryption: map['encryption'] ?? '',
      password: map['wpa-pre-shared-key'] ?? map['wpa2-pre-shared-key'] ?? '',
      mode: map['mode'] ?? 'dynamic-keys',
      managementProtection: map['management-protection'] == 'allowed',
      wpaPreSharedKey: int.tryParse(map['wpa-pre-shared-key'] ?? '0') ?? 0,
      wpa2PreSharedKey: int.tryParse(map['wpa2-pre-shared-key'] ?? '0') ?? 0,
    );
  }

  factory SecurityProfileModel.fromEntity(SecurityProfile entity) {
    return SecurityProfileModel(
      id: entity.id,
      name: entity.name,
      authentication: entity.authentication,
      encryption: entity.encryption,
      password: entity.password,
      mode: entity.mode,
      managementProtection: entity.managementProtection,
      wpaPreSharedKey: entity.wpaPreSharedKey,
      wpa2PreSharedKey: entity.wpa2PreSharedKey,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'name': name,
      'authentication-types': authentication,
      'encryption': encryption,
      'wpa-pre-shared-key': password,
      'wpa2-pre-shared-key': password,
      'mode': mode,
      'management-protection': managementProtection ? 'allowed' : 'disabled',
    };
  }
}