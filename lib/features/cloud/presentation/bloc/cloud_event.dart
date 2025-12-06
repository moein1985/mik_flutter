import 'package:equatable/equatable.dart';

abstract class CloudEvent extends Equatable {
  const CloudEvent();

  @override
  List<Object?> get props => [];
}

class LoadCloudStatus extends CloudEvent {
  const LoadCloudStatus();
}

class EnableCloudDdns extends CloudEvent {
  const EnableCloudDdns();
}

class DisableCloudDdns extends CloudEvent {
  const DisableCloudDdns();
}

class ForceUpdateDdns extends CloudEvent {
  const ForceUpdateDdns();
}

class SetDdnsUpdateInterval extends CloudEvent {
  final String interval;

  const SetDdnsUpdateInterval(this.interval);

  @override
  List<Object> get props => [interval];
}

class SetCloudUpdateTime extends CloudEvent {
  final bool enabled;

  const SetCloudUpdateTime(this.enabled);

  @override
  List<Object> get props => [enabled];
}
