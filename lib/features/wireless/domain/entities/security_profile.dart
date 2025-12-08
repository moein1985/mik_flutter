import 'package:equatable/equatable.dart';

class SecurityProfile extends Equatable {
  final String id;
  final String name;
  final String authentication;
  final String encryption;
  final String password;
  final String mode;
  final bool managementProtection;
  final int wpaPreSharedKey;
  final int wpa2PreSharedKey;

  const SecurityProfile({
    required this.id,
    required this.name,
    required this.authentication,
    required this.encryption,
    required this.password,
    required this.mode,
    required this.managementProtection,
    required this.wpaPreSharedKey,
    required this.wpa2PreSharedKey,
  });

  factory SecurityProfile.fromMap(Map<String, dynamic> map) {
    return SecurityProfile(
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

  // Helper method to get authentication type display name
  String get authenticationDisplayName {
    switch (authentication) {
      case 'wpa-psk':
        return 'WPA Personal';
      case 'wpa2-psk':
        return 'WPA2 Personal';
      case 'wpa3-psk':
        return 'WPA3 Personal';
      case 'wpa-eap':
        return 'WPA Enterprise';
      case 'wpa2-eap':
        return 'WPA2 Enterprise';
      default:
        return authentication;
    }
  }

  // Helper method to get encryption display name
  String get encryptionDisplayName {
    switch (encryption) {
      case 'aes-ccm':
        return 'AES-CCM';
      case 'tkip':
        return 'TKIP';
      case 'aes-ccmp':
        return 'AES-CCMP';
      default:
        return encryption;
    }
  }

  SecurityProfile copyWith({
    String? id,
    String? name,
    String? authentication,
    String? encryption,
    String? password,
    String? mode,
    bool? managementProtection,
    int? wpaPreSharedKey,
    int? wpa2PreSharedKey,
  }) {
    return SecurityProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      authentication: authentication ?? this.authentication,
      encryption: encryption ?? this.encryption,
      password: password ?? this.password,
      mode: mode ?? this.mode,
      managementProtection: managementProtection ?? this.managementProtection,
      wpaPreSharedKey: wpaPreSharedKey ?? this.wpaPreSharedKey,
      wpa2PreSharedKey: wpa2PreSharedKey ?? this.wpa2PreSharedKey,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        authentication,
        encryption,
        password,
        mode,
        managementProtection,
        wpaPreSharedKey,
        wpa2PreSharedKey,
      ];
}