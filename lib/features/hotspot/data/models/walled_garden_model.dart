import '../../domain/entities/walled_garden.dart';

class WalledGardenModel extends WalledGarden {
  const WalledGardenModel({
    required super.id,
    super.server,
    super.srcAddress,
    super.dstAddress,
    super.dstHost,
    super.dstPort,
    super.path,
    required super.action,
    super.method,
    super.comment,
    required super.disabled,
  });

  factory WalledGardenModel.fromMap(Map<String, dynamic> map) {
    return WalledGardenModel(
      id: map['.id'] ?? '',
      server: map['server'],
      srcAddress: map['src-address'],
      dstAddress: map['dst-address'],
      dstHost: map['dst-host'],
      dstPort: map['dst-port'],
      path: map['path'],
      action: map['action'] ?? 'allow',
      method: map['method'],
      comment: map['comment'],
      disabled: map['disabled'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '.id': id,
      if (server != null) 'server': server,
      if (srcAddress != null) 'src-address': srcAddress,
      if (dstAddress != null) 'dst-address': dstAddress,
      if (dstHost != null) 'dst-host': dstHost,
      if (dstPort != null) 'dst-port': dstPort,
      if (path != null) 'path': path,
      'action': action,
      if (method != null) 'method': method,
      if (comment != null) 'comment': comment,
      'disabled': disabled ? 'true' : 'false',
    };
  }

  factory WalledGardenModel.fromEntity(WalledGarden entity) {
    return WalledGardenModel(
      id: entity.id,
      server: entity.server,
      srcAddress: entity.srcAddress,
      dstAddress: entity.dstAddress,
      dstHost: entity.dstHost,
      dstPort: entity.dstPort,
      path: entity.path,
      action: entity.action,
      method: entity.method,
      comment: entity.comment,
      disabled: entity.disabled,
    );
  }
}
