import 'package:equatable/equatable.dart';
import '../../domain/entities/hotspot_server.dart';
import '../../domain/entities/hotspot_user.dart';
import '../../domain/entities/hotspot_active_user.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/hotspot_ip_binding.dart';
import '../../domain/entities/hotspot_host.dart';
import '../../domain/entities/walled_garden.dart';

abstract class HotspotState extends Equatable {
  const HotspotState();

  @override
  List<Object?> get props => [];
}

class HotspotInitial extends HotspotState {
  const HotspotInitial();
}

class HotspotLoading extends HotspotState {
  const HotspotLoading();
}

class HotspotLoaded extends HotspotState {
  final List<HotspotServer>? servers;
  final List<HotspotUser>? users;
  final List<HotspotActiveUser>? activeUsers;
  final List<HotspotProfile>? profiles;
  final List<HotspotIpBinding>? ipBindings;
  final List<HotspotHost>? hosts;
  final List<WalledGarden>? walledGarden;

  const HotspotLoaded({
    this.servers,
    this.users,
    this.activeUsers,
    this.profiles,
    this.ipBindings,
    this.hosts,
    this.walledGarden,
  });

  HotspotLoaded copyWith({
    List<HotspotServer>? servers,
    List<HotspotUser>? users,
    List<HotspotActiveUser>? activeUsers,
    List<HotspotProfile>? profiles,
    List<HotspotIpBinding>? ipBindings,
    List<HotspotHost>? hosts,
    List<WalledGarden>? walledGarden,
  }) {
    return HotspotLoaded(
      servers: servers ?? this.servers,
      users: users ?? this.users,
      activeUsers: activeUsers ?? this.activeUsers,
      profiles: profiles ?? this.profiles,
      ipBindings: ipBindings ?? this.ipBindings,
      hosts: hosts ?? this.hosts,
      walledGarden: walledGarden ?? this.walledGarden,
    );
  }

  @override
  List<Object?> get props => [servers, users, activeUsers, profiles, ipBindings, hosts, walledGarden];
}

class HotspotError extends HotspotState {
  final String message;

  const HotspotError(this.message);

  @override
  List<Object> get props => [message];
}

class HotspotOperationSuccess extends HotspotState {
  final String message;
  // Preserve the last loaded data to avoid losing state
  final HotspotLoaded? previousData;

  const HotspotOperationSuccess(this.message, {this.previousData});

  @override
  List<Object?> get props => [message, previousData];
}

class HotspotPackageDisabled extends HotspotState {
  const HotspotPackageDisabled();
}

class HotspotSetupDataLoaded extends HotspotState {
  final List<Map<String, String>> interfaces;
  final List<Map<String, String>> ipPools;
  final List<Map<String, String>> ipAddresses;

  const HotspotSetupDataLoaded({
    required this.interfaces,
    required this.ipPools,
    required this.ipAddresses,
  });

  HotspotSetupDataLoaded copyWith({
    List<Map<String, String>>? interfaces,
    List<Map<String, String>>? ipPools,
    List<Map<String, String>>? ipAddresses,
  }) {
    return HotspotSetupDataLoaded(
      interfaces: interfaces ?? this.interfaces,
      ipPools: ipPools ?? this.ipPools,
      ipAddresses: ipAddresses ?? this.ipAddresses,
    );
  }

  @override
  List<Object> get props => [interfaces, ipPools, ipAddresses];
}

// ==================== Reset HotSpot States ====================

class HotspotResetInProgress extends HotspotState {
  final String currentStep;

  const HotspotResetInProgress(this.currentStep);

  @override
  List<Object> get props => [currentStep];
}

class HotspotResetSuccess extends HotspotState {
  const HotspotResetSuccess();
}
