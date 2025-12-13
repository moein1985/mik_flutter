import 'package:equatable/equatable.dart';

class AccessListEntry extends Equatable {
  final String id;
  final String macAddress;
  final String interface;
  final bool authentication; // true = allow, false = deny
  final bool forwarding;
  final String? apTxLimit;
  final String? clientTxLimit;
  final String? signalRange;
  final String? time;
  final String? comment;

  const AccessListEntry({
    required this.id,
    required this.macAddress,
    required this.interface,
    required this.authentication,
    required this.forwarding,
    this.apTxLimit,
    this.clientTxLimit,
    this.signalRange,
    this.time,
    this.comment,
  });

  @override
  List<Object?> get props => [
        id,
        macAddress,
        interface,
        authentication,
        forwarding,
        apTxLimit,
        clientTxLimit,
        signalRange,
        time,
        comment,
      ];
}
