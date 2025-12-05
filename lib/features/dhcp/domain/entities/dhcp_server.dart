import 'package:equatable/equatable.dart';

class DhcpServer extends Equatable {
  final String id;
  final String name;
  final String interface;
  final String? addressPool;
  final String leaseTime;
  final bool disabled;
  final bool invalid;
  final bool authoritative;
  final String? useRadius;
  final String? relayAddress;

  const DhcpServer({
    required this.id,
    required this.name,
    required this.interface,
    this.addressPool,
    required this.leaseTime,
    required this.disabled,
    required this.invalid,
    required this.authoritative,
    this.useRadius,
    this.relayAddress,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        interface,
        addressPool,
        leaseTime,
        disabled,
        invalid,
        authoritative,
        useRadius,
        relayAddress,
      ];
}
