import 'package:equatable/equatable.dart';

class IpAddress extends Equatable {
  final String id;
  final String address;
  final String network;
  final String interfaceName;
  final bool disabled;
  final bool invalid;
  final bool dynamic;
  final String? comment;

  const IpAddress({
    required this.id,
    required this.address,
    required this.network,
    required this.interfaceName,
    required this.disabled,
    required this.invalid,
    required this.dynamic,
    this.comment,
  });

  @override
  List<Object?> get props => [
        id,
        address,
        network,
        interfaceName,
        disabled,
        invalid,
        dynamic,
        comment,
      ];
}
