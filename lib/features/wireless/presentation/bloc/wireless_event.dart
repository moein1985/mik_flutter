import '../../domain/entities/security_profile.dart';
import '../../domain/entities/access_list_entry.dart';

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

class ScanWirelessNetworks extends WirelessEvent {
  final String interfaceId;
  final int? duration;

  const ScanWirelessNetworks({
    required this.interfaceId,
    this.duration,
  });
}

class LoadAccessList extends WirelessEvent {
  const LoadAccessList();
}

class AddAccessListEntry extends WirelessEvent {
  final AccessListEntry entry;

  const AddAccessListEntry(this.entry);
}

class RemoveAccessListEntry extends WirelessEvent {
  final String id;

  const RemoveAccessListEntry(this.id);
}

class UpdateAccessListEntry extends WirelessEvent {
  final AccessListEntry entry;

  const UpdateAccessListEntry(this.entry);
}
// Quick settings events
class UpdateWirelessSsid extends WirelessEvent {
  final String interfaceId;
  final String newSsid;

  const UpdateWirelessSsid(this.interfaceId, this.newSsid);
}

class GetWirelessPassword extends WirelessEvent {
  final String securityProfileName;

  const GetWirelessPassword(this.securityProfileName);
}

class UpdateWirelessPassword extends WirelessEvent {
  final String securityProfileName;
  final String newPassword;

  const UpdateWirelessPassword(this.securityProfileName, this.newPassword);
}

// Virtual WLAN events
class AddVirtualWirelessInterface extends WirelessEvent {
  final String ssid;
  final String masterInterface;
  final String? name;
  final String? securityProfile;
  final bool enabled;

  const AddVirtualWirelessInterface({
    required this.ssid,
    required this.masterInterface,
    this.name,
    this.securityProfile,
    this.enabled = true,
  });
}