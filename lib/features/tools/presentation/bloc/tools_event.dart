import 'package:equatable/equatable.dart';

/// Base class for all Tools events
abstract class ToolsEvent extends Equatable {
  const ToolsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start ping operation
class StartPing extends ToolsEvent {
  final String target;
  final int count;
  final int timeout;

  const StartPing({
    required this.target,
    this.count = 4,
    this.timeout = 1000,
  });

  @override
  List<Object?> get props => [target, count, timeout];
}

/// Event to stop ping operation
class StopPing extends ToolsEvent {
  const StopPing();
}

/// Event to stop traceroute operation
class StopTraceroute extends ToolsEvent {
  const StopTraceroute();
}

/// Event to start traceroute operation
class StartTraceroute extends ToolsEvent {
  final String target;
  final int maxHops;
  final int timeout;

  const StartTraceroute({
    required this.target,
    this.maxHops = 30,
    this.timeout = 1000,
  });

  @override
  List<Object?> get props => [target, maxHops, timeout];
}

/// Event to start DNS lookup operation
class StartDnsLookup extends ToolsEvent {
  final String domain;
  final int timeout;

  const StartDnsLookup({
    required this.domain,
    this.timeout = 5000,
  });

  @override
  List<Object?> get props => [domain, timeout];
}

/// Event to clear current results
class ClearResults extends ToolsEvent {
  const ClearResults();
}