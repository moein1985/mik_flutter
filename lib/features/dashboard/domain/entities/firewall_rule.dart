import 'package:equatable/equatable.dart';

class FirewallRule extends Equatable {
  final String id;
  final String chain;
  final String action;
  final bool disabled;
  final bool invalid;
  final bool dynamic;
  final String? srcAddress;
  final String? dstAddress;
  final String? protocol;
  final String? dstPort;
  final String? comment;
  final int? bytes;
  final int? packets;

  const FirewallRule({
    required this.id,
    required this.chain,
    required this.action,
    required this.disabled,
    required this.invalid,
    required this.dynamic,
    this.srcAddress,
    this.dstAddress,
    this.protocol,
    this.dstPort,
    this.comment,
    this.bytes,
    this.packets,
  });

  @override
  List<Object?> get props => [
        id,
        chain,
        action,
        disabled,
        invalid,
        dynamic,
        srcAddress,
        dstAddress,
        protocol,
        dstPort,
        comment,
        bytes,
        packets,
      ];
}
