import 'package:equatable/equatable.dart';

class HotspotUser extends Equatable {
  final String id;
  final String name;
  final String? password;
  final String? profile;
  final String? server;
  final String? uptime;
  final String? bytesIn;
  final String? bytesOut;
  final String? packetsIn;
  final String? packetsOut;
  final String? comment;
  final bool disabled;

  const HotspotUser({
    required this.id,
    required this.name,
    this.password,
    this.profile,
    this.server,
    this.uptime,
    this.bytesIn,
    this.bytesOut,
    this.packetsIn,
    this.packetsOut,
    this.comment,
    required this.disabled,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        password,
        profile,
        server,
        uptime,
        bytesIn,
        bytesOut,
        packetsIn,
        packetsOut,
        comment,
        disabled,
      ];
}
