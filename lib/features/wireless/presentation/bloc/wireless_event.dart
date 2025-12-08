import '../../domain/entities/security_profile.dart';

abstract class WirelessEvent {
  const WirelessEvent();
}

class LoadWirelessInterfaces extends WirelessEvent {
  const LoadWirelessInterfaces();
}

class EnableWirelessInterface extends WirelessEvent {
  final String interfaceId;

  const EnableWirelessInterface(this.interfaceId);
}

class DisableWirelessInterface extends WirelessEvent {
  final String interfaceId;

  const DisableWirelessInterface(this.interfaceId);
}

class LoadWirelessRegistrations extends WirelessEvent {
  const LoadWirelessRegistrations();
}

class LoadRegistrationsByInterface extends WirelessEvent {
  final String interfaceName;

  const LoadRegistrationsByInterface(this.interfaceName);
}

class DisconnectWirelessClient extends WirelessEvent {
  final String macAddress;
  final String interfaceName;

  const DisconnectWirelessClient(this.macAddress, this.interfaceName);
}

class LoadSecurityProfiles extends WirelessEvent {
  const LoadSecurityProfiles();
}

class CreateSecurityProfile extends WirelessEvent {
  final SecurityProfile profile;

  const CreateSecurityProfile(this.profile);
}

class UpdateSecurityProfile extends WirelessEvent {
  final SecurityProfile profile;

  const UpdateSecurityProfile(this.profile);
}

class DeleteSecurityProfile extends WirelessEvent {
  final String profileId;

  const DeleteSecurityProfile(this.profileId);
}