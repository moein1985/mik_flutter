import 'package:equatable/equatable.dart';

class HotspotServer extends Equatable {
  final String id;
  final String name;
  final String interfaceName;
  final String addressPool;
  final String? profile;
  final bool disabled;

  const HotspotServer({
    required this.id,
    required this.name,
    required this.interfaceName,
    required this.addressPool,
    this.profile,
    required this.disabled,
  });

  @override
  List<Object?> get props => [id, name, interfaceName, addressPool, profile, disabled];
}
