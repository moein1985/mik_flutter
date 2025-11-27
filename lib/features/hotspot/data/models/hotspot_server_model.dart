import '../../domain/entities/hotspot_server.dart';

class HotspotServerModel extends HotspotServer {
  const HotspotServerModel({
    required super.id,
    required super.name,
    required super.interfaceName,
    required super.addressPool,
    super.profile,
    required super.disabled,
  });

  factory HotspotServerModel.fromMap(Map<String, dynamic> map) {
    return HotspotServerModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      interfaceName: map['interface'] ?? '',
      addressPool: map['address-pool'] ?? '',
      profile: map['profile'],
      disabled: map['disabled'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      'name': name,
      'interface': interfaceName,
      'address-pool': addressPool,
      if (profile != null) 'profile': profile,
      'disabled': disabled ? 'true' : 'false',
    };
  }
}
