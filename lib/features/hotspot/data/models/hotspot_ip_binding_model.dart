import '../../domain/entities/hotspot_ip_binding.dart';

class HotspotIpBindingModel extends HotspotIpBinding {
  const HotspotIpBindingModel({
    required super.id,
    super.mac,
    super.address,
    super.toAddress,
    super.server,
    required super.type,
    super.comment,
    required super.disabled,
  });

  factory HotspotIpBindingModel.fromMap(Map<String, dynamic> map) {
    return HotspotIpBindingModel(
      id: map['.id'] ?? '',
      mac: map['mac-address'],
      address: map['address'],
      toAddress: map['to-address'],
      server: map['server'],
      type: map['type'] ?? 'regular',
      comment: map['comment'],
      disabled: map['disabled'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      if (mac != null) 'mac-address': mac,
      if (address != null) 'address': address,
      if (toAddress != null) 'to-address': toAddress,
      if (server != null) 'server': server,
      'type': type,
      if (comment != null) 'comment': comment,
      'disabled': disabled ? 'true' : 'false',
    };
  }

  factory HotspotIpBindingModel.fromEntity(HotspotIpBinding entity) {
    return HotspotIpBindingModel(
      id: entity.id,
      mac: entity.mac,
      address: entity.address,
      toAddress: entity.toAddress,
      server: entity.server,
      type: entity.type,
      comment: entity.comment,
      disabled: entity.disabled,
    );
  }
}
