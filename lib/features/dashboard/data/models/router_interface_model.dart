import '../../domain/entities/router_interface.dart';

class RouterInterfaceModel extends RouterInterface {
  const RouterInterfaceModel({
    required super.id,
    required super.name,
    required super.type,
    required super.running,
    required super.disabled,
    super.comment,
    super.macAddress,
  });

  factory RouterInterfaceModel.fromMap(Map<String, String> map) {
    return RouterInterfaceModel(
      id: map['.id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      running: map['running'] == 'true',
      disabled: map['disabled'] == 'true',
      comment: map['comment'],
      macAddress: map['mac-address'],
    );
  }
}
