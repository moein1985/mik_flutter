import 'package:equatable/equatable.dart';

class CloudStatus extends Equatable {
  final bool ddnsEnabled;
  final String? ddnsUpdateInterval;
  final bool updateTime;
  final String? publicAddress;
  final String? dnsName;
  final String? status;
  final String? backToHomeVpn;
  final String? warning; // For "Cloud services not supported on x86"
  final bool isSupported; // true if hardware router, false if x86/CHR

  const CloudStatus({
    required this.ddnsEnabled,
    this.ddnsUpdateInterval,
    required this.updateTime,
    this.publicAddress,
    this.dnsName,
    this.status,
    this.backToHomeVpn,
    this.warning,
    this.isSupported = true,
  });

  @override
  List<Object?> get props => [
        ddnsEnabled,
        ddnsUpdateInterval,
        updateTime,
        publicAddress,
        dnsName,
        status,
        backToHomeVpn,
        warning,
        isSupported,
      ];

  CloudStatus copyWith({
    bool? ddnsEnabled,
    String? ddnsUpdateInterval,
    bool? updateTime,
    String? publicAddress,
    String? dnsName,
    String? status,
    String? backToHomeVpn,
    String? warning,
    bool? isSupported,
  }) {
    return CloudStatus(
      ddnsEnabled: ddnsEnabled ?? this.ddnsEnabled,
      ddnsUpdateInterval: ddnsUpdateInterval ?? this.ddnsUpdateInterval,
      updateTime: updateTime ?? this.updateTime,
      publicAddress: publicAddress ?? this.publicAddress,
      dnsName: dnsName ?? this.dnsName,
      status: status ?? this.status,
      backToHomeVpn: backToHomeVpn ?? this.backToHomeVpn,
      warning: warning ?? this.warning,
      isSupported: isSupported ?? this.isSupported,
    );
  }
}
