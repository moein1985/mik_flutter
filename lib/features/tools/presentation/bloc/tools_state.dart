import 'package:equatable/equatable.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../../domain/entities/ping_result.dart';
import '../../domain/entities/traceroute_hop.dart';

/// Sealed class for all Tools states with exhaustive matching
sealed class ToolsState extends Equatable {
  const ToolsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when Tools page is first loaded
final class ToolsInitial extends ToolsState {
  const ToolsInitial();
}

/// State when ping operation is in progress
final class PingInProgress extends ToolsState {
  const PingInProgress();
}

/// State when ping operation is updating with new packets (non-nullable!)
final class PingUpdating extends ToolsState {
  final PingResult result;

  const PingUpdating(this.result);

  @override
  List<Object?> get props => [result];
}

/// State when ping operation is completed (non-nullable!)
final class PingCompleted extends ToolsState {
  final PingResult result;

  const PingCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

/// State when ping operation failed
final class PingFailed extends ToolsState {
  final String error;

  const PingFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// State when traceroute operation is in progress
final class TracerouteInProgress extends ToolsState {
  const TracerouteInProgress();
}

/// State when traceroute operation is updating with new hops (non-nullable!)
final class TracerouteUpdating extends ToolsState {
  final List<TracerouteHop> hops;

  const TracerouteUpdating(this.hops);

  @override
  List<Object?> get props => [hops];
}

/// State when traceroute operation is completed (non-nullable!)
final class TracerouteCompleted extends ToolsState {
  final List<TracerouteHop> hops;

  const TracerouteCompleted(this.hops);

  @override
  List<Object?> get props => [hops];
}

/// State when traceroute operation failed
final class TracerouteFailed extends ToolsState {
  final String error;

  const TracerouteFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// State when DNS lookup operation is in progress
final class DnsLookupInProgress extends ToolsState {
  const DnsLookupInProgress();
}

/// State when DNS lookup operation is completed (non-nullable!)
final class DnsLookupCompleted extends ToolsState {
  final DnsLookupResult result;

  const DnsLookupCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

/// State when DNS lookup operation failed
final class DnsLookupFailed extends ToolsState {
  final String error;

  const DnsLookupFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// State when any operation encounters an error
final class ToolsError extends ToolsState {
  final String message;

  const ToolsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State containing network info for ping options (non-nullable!)
final class NetworkInfoLoaded extends ToolsState {
  final List<String> interfaces;
  final List<String> ipAddresses;

  const NetworkInfoLoaded({
    required this.interfaces,
    required this.ipAddresses,
  });

  @override
  List<Object?> get props => [interfaces, ipAddresses];
}