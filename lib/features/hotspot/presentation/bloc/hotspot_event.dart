import 'package:equatable/equatable.dart';

abstract class HotspotEvent extends Equatable {
  const HotspotEvent();

  @override
  List<Object?> get props => [];
}

class LoadHotspotServers extends HotspotEvent {
  const LoadHotspotServers();
}

class LoadHotspotUsers extends HotspotEvent {
  const LoadHotspotUsers();
}

class LoadHotspotActiveUsers extends HotspotEvent {
  const LoadHotspotActiveUsers();
}

class LoadHotspotProfiles extends HotspotEvent {
  const LoadHotspotProfiles();
}

class AddHotspotUser extends HotspotEvent {
  final String name;
  final String password;
  final String? profile;
  final String? server;
  final String? comment;
  // Limits
  final String? limitUptime;
  final String? limitBytesIn;
  final String? limitBytesOut;
  final String? limitBytesTotal;

  const AddHotspotUser({
    required this.name,
    required this.password,
    this.profile,
    this.server,
    this.comment,
    this.limitUptime,
    this.limitBytesIn,
    this.limitBytesOut,
    this.limitBytesTotal,
  });

  @override
  List<Object?> get props => [
        name,
        password,
        profile,
        server,
        comment,
        limitUptime,
        limitBytesIn,
        limitBytesOut,
        limitBytesTotal,
      ];
}

class EditHotspotUser extends HotspotEvent {
  final String id;
  final String? name;
  final String? password;
  final String? profile;
  final String? server;
  final String? comment;
  // Limits
  final String? limitUptime;
  final String? limitBytesIn;
  final String? limitBytesOut;
  final String? limitBytesTotal;

  const EditHotspotUser({
    required this.id,
    this.name,
    this.password,
    this.profile,
    this.server,
    this.comment,
    this.limitUptime,
    this.limitBytesIn,
    this.limitBytesOut,
    this.limitBytesTotal,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        password,
        profile,
        server,
        comment,
        limitUptime,
        limitBytesIn,
        limitBytesOut,
        limitBytesTotal,
      ];
}

class DeleteHotspotUser extends HotspotEvent {
  final String id;

  const DeleteHotspotUser(this.id);

  @override
  List<Object> get props => [id];
}

class ResetHotspotUserCounters extends HotspotEvent {
  final String id;

  const ResetHotspotUserCounters(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleHotspotUser extends HotspotEvent {
  final String id;
  final bool enable;

  const ToggleHotspotUser({
    required this.id,
    required this.enable,
  });

  @override
  List<Object> get props => [id, enable];
}

class DisconnectHotspotUser extends HotspotEvent {
  final String id;

  const DisconnectHotspotUser(this.id);

  @override
  List<Object> get props => [id];
}

class SetupHotspot extends HotspotEvent {
  final String interface;
  final String? addressPool;
  final String? dnsName;

  const SetupHotspot({
    required this.interface,
    this.addressPool,
    this.dnsName,
  });

  @override
  List<Object?> get props => [interface, addressPool, dnsName];
}

class CheckHotspotPackage extends HotspotEvent {
  const CheckHotspotPackage();
}

class LoadSetupData extends HotspotEvent {
  const LoadSetupData();
}

class AddIpPool extends HotspotEvent {
  final String name;
  final String ranges;

  const AddIpPool({
    required this.name,
    required this.ranges,
  });

  @override
  List<Object> get props => [name, ranges];
}
