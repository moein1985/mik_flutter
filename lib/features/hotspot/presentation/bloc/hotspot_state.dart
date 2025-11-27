import 'package:equatable/equatable.dart';
import '../../domain/entities/hotspot_server.dart';
import '../../domain/entities/hotspot_user.dart';
import '../../domain/entities/hotspot_active_user.dart';
import '../../domain/entities/hotspot_profile.dart';

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

  const HotspotLoaded({
    this.servers,
    this.users,
    this.activeUsers,
    this.profiles,
  });

  HotspotLoaded copyWith({
    List<HotspotServer>? servers,
    List<HotspotUser>? users,
    List<HotspotActiveUser>? activeUsers,
    List<HotspotProfile>? profiles,
  }) {
    return HotspotLoaded(
      servers: servers ?? this.servers,
      users: users ?? this.users,
      activeUsers: activeUsers ?? this.activeUsers,
      profiles: profiles ?? this.profiles,
    );
  }

  @override
  List<Object?> get props => [servers, users, activeUsers, profiles];
}

class HotspotError extends HotspotState {
  final String message;

  const HotspotError(this.message);

  @override
  List<Object> get props => [message];
}

class HotspotOperationSuccess extends HotspotState {
  final String message;

  const HotspotOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
