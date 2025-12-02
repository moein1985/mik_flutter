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

// ==================== IP Binding Events ====================

class LoadIpBindings extends HotspotEvent {
  const LoadIpBindings();
}

class AddIpBinding extends HotspotEvent {
  final String? mac;
  final String? address;
  final String? toAddress;
  final String? server;
  final String type;
  final String? comment;

  const AddIpBinding({
    this.mac,
    this.address,
    this.toAddress,
    this.server,
    this.type = 'regular',
    this.comment,
  });

  @override
  List<Object?> get props => [mac, address, toAddress, server, type, comment];
}

class EditIpBinding extends HotspotEvent {
  final String id;
  final String? mac;
  final String? address;
  final String? toAddress;
  final String? server;
  final String? type;
  final String? comment;

  const EditIpBinding({
    required this.id,
    this.mac,
    this.address,
    this.toAddress,
    this.server,
    this.type,
    this.comment,
  });

  @override
  List<Object?> get props => [id, mac, address, toAddress, server, type, comment];
}

class DeleteIpBinding extends HotspotEvent {
  final String id;

  const DeleteIpBinding(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleIpBinding extends HotspotEvent {
  final String id;
  final bool enable;

  const ToggleIpBinding({
    required this.id,
    required this.enable,
  });

  @override
  List<Object> get props => [id, enable];
}

// ==================== Hosts Events ====================

class LoadHosts extends HotspotEvent {
  const LoadHosts();
}

class RemoveHost extends HotspotEvent {
  final String id;

  const RemoveHost(this.id);

  @override
  List<Object> get props => [id];
}

class MakeHostBinding extends HotspotEvent {
  final String id;
  final String type; // 'bypassed' or 'blocked'

  const MakeHostBinding({
    required this.id,
    required this.type,
  });

  @override
  List<Object> get props => [id, type];
}

// ==================== Walled Garden Events ====================

class LoadWalledGarden extends HotspotEvent {
  const LoadWalledGarden();
}

class AddWalledGarden extends HotspotEvent {
  final String? server;
  final String? srcAddress;
  final String? dstAddress;
  final String? dstHost;
  final String? dstPort;
  final String? path;
  final String action;
  final String? method;
  final String? comment;

  const AddWalledGarden({
    this.server,
    this.srcAddress,
    this.dstAddress,
    this.dstHost,
    this.dstPort,
    this.path,
    this.action = 'allow',
    this.method,
    this.comment,
  });

  @override
  List<Object?> get props => [server, srcAddress, dstAddress, dstHost, dstPort, path, action, method, comment];
}

class EditWalledGarden extends HotspotEvent {
  final String id;
  final String? server;
  final String? srcAddress;
  final String? dstAddress;
  final String? dstHost;
  final String? dstPort;
  final String? path;
  final String? action;
  final String? method;
  final String? comment;

  const EditWalledGarden({
    required this.id,
    this.server,
    this.srcAddress,
    this.dstAddress,
    this.dstHost,
    this.dstPort,
    this.path,
    this.action,
    this.method,
    this.comment,
  });

  @override
  List<Object?> get props => [id, server, srcAddress, dstAddress, dstHost, dstPort, path, action, method, comment];
}

class DeleteWalledGarden extends HotspotEvent {
  final String id;

  const DeleteWalledGarden(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleWalledGarden extends HotspotEvent {
  final String id;
  final bool enable;

  const ToggleWalledGarden({
    required this.id,
    required this.enable,
  });

  @override
  List<Object> get props => [id, enable];
}

// ==================== Profile CRUD Events ====================

class AddHotspotProfile extends HotspotEvent {
  final String name;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? sharedUsers;
  final String? rateLimit;
  final String? keepaliveTimeout;
  final String? statusAutorefresh;
  final String? onLogin;
  final String? onLogout;

  const AddHotspotProfile({
    required this.name,
    this.sessionTimeout,
    this.idleTimeout,
    this.sharedUsers,
    this.rateLimit,
    this.keepaliveTimeout,
    this.statusAutorefresh,
    this.onLogin,
    this.onLogout,
  });

  @override
  List<Object?> get props => [name, sessionTimeout, idleTimeout, sharedUsers, rateLimit, keepaliveTimeout, statusAutorefresh, onLogin, onLogout];
}

class EditHotspotProfile extends HotspotEvent {
  final String id;
  final String? name;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? sharedUsers;
  final String? rateLimit;
  final String? keepaliveTimeout;
  final String? statusAutorefresh;
  final String? onLogin;
  final String? onLogout;

  const EditHotspotProfile({
    required this.id,
    this.name,
    this.sessionTimeout,
    this.idleTimeout,
    this.sharedUsers,
    this.rateLimit,
    this.keepaliveTimeout,
    this.statusAutorefresh,
    this.onLogin,
    this.onLogout,
  });

  @override
  List<Object?> get props => [id, name, sessionTimeout, idleTimeout, sharedUsers, rateLimit, keepaliveTimeout, statusAutorefresh, onLogin, onLogout];
}

class DeleteHotspotProfile extends HotspotEvent {
  final String id;

  const DeleteHotspotProfile(this.id);

  @override
  List<Object> get props => [id];
}

// ==================== Reset HotSpot Event ====================

class ResetHotspot extends HotspotEvent {
  final bool deleteUsers;
  final bool deleteProfiles;
  final bool deleteIpBindings;
  final bool deleteWalledGarden;
  final bool deleteServers;
  final bool deleteServerProfiles;
  final bool deleteIpPools;

  const ResetHotspot({
    this.deleteUsers = true,
    this.deleteProfiles = true,
    this.deleteIpBindings = true,
    this.deleteWalledGarden = true,
    this.deleteServers = true,
    this.deleteServerProfiles = true,
    this.deleteIpPools = false,
  });

  @override
  List<Object> get props => [
        deleteUsers,
        deleteProfiles,
        deleteIpBindings,
        deleteWalledGarden,
        deleteServers,
        deleteServerProfiles,
        deleteIpPools,
      ];
}
