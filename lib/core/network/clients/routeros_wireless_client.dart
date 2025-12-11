import 'routeros_base_client.dart';

/// Specialized client for RouterOS wireless operations
class RouterOSWirelessClient extends RouterOSBaseClient {
  RouterOSWirelessClient({
    required super.host,
    required super.port,
    required super.useSsl,
  });

  /// Get wireless interfaces
  Future<List<Map<String, String>>> getWirelessInterfaces() async {
    return sendCommand(['/interface/wireless/print']);
  }

  /// Enable wireless interface
  Future<bool> enableWirelessInterface(String id) async {
    final result = await sendCommand(['/interface/wireless/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable wireless interface
  Future<bool> disableWirelessInterface(String id) async {
    final result = await sendCommand(['/interface/wireless/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Get wireless registrations
  Future<List<Map<String, String>>> getWirelessRegistrations({
    String? interface,
  }) async {
    final words = ['/interface/wireless/registration-table/print'];
    if (interface != null) words.add('=interface=$interface');

    return sendCommand(words);
  }

  /// Disconnect wireless client
  Future<bool> disconnectWirelessClient({
    required String interface,
    required String macAddress,
  }) async {
    final result = await sendCommand([
      '/interface/wireless/registration-table/remove',
      '=interface=$interface',
      '=mac-address=$macAddress'
    ]);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Get wireless security profiles
  Future<List<Map<String, String>>> getWirelessSecurityProfiles() async {
    return sendCommand(['/interface/wireless/security-profiles/print']);
  }

  /// Create wireless security profile
  Future<bool> createWirelessSecurityProfile({
    required String name,
    String? authenticationTypes,
    String? unicastCiphers,
    String? groupCiphers,
    String? wpaPreSharedKey,
    String? wpa2PreSharedKey,
    String? supplicantIdentity,
    String? eapMethods,
    String? tlsCertificate,
    String? tlsMode,
    String? comment,
  }) async {
    final words = ['/interface/wireless/security-profiles/add', '=name=$name'];
    if (authenticationTypes != null) words.add('=authentication-types=$authenticationTypes');
    if (unicastCiphers != null) words.add('=unicast-ciphers=$unicastCiphers');
    if (groupCiphers != null) words.add('=group-ciphers=$groupCiphers');
    if (wpaPreSharedKey != null) words.add('=wpa-pre-shared-key=$wpaPreSharedKey');
    if (wpa2PreSharedKey != null) words.add('=wpa2-pre-shared-key=$wpa2PreSharedKey');
    if (supplicantIdentity != null) words.add('=supplicant-identity=$supplicantIdentity');
    if (eapMethods != null) words.add('=eap-methods=$eapMethods');
    if (tlsCertificate != null) words.add('=tls-certificate=$tlsCertificate');
    if (tlsMode != null) words.add('=tls-mode=$tlsMode');
    if (comment != null) words.add('=comment=$comment');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Update wireless security profile
  Future<bool> updateWirelessSecurityProfile({
    required String id,
    String? name,
    String? authenticationTypes,
    String? unicastCiphers,
    String? groupCiphers,
    String? wpaPreSharedKey,
    String? wpa2PreSharedKey,
    String? supplicantIdentity,
    String? eapMethods,
    String? tlsCertificate,
    String? tlsMode,
    String? comment,
  }) async {
    final words = ['/interface/wireless/security-profiles/set', '=.id=$id'];
    if (name != null) words.add('=name=$name');
    if (authenticationTypes != null) words.add('=authentication-types=$authenticationTypes');
    if (unicastCiphers != null) words.add('=unicast-ciphers=$unicastCiphers');
    if (groupCiphers != null) words.add('=group-ciphers=$groupCiphers');
    if (wpaPreSharedKey != null) words.add('=wpa-pre-shared-key=$wpaPreSharedKey');
    if (wpa2PreSharedKey != null) words.add('=wpa2-pre-shared-key=$wpa2PreSharedKey');
    if (supplicantIdentity != null) words.add('=supplicant-identity=$supplicantIdentity');
    if (eapMethods != null) words.add('=eap-methods=$eapMethods');
    if (tlsCertificate != null) words.add('=tls-certificate=$tlsCertificate');
    if (tlsMode != null) words.add('=tls-mode=$tlsMode');
    if (comment != null) words.add('=comment=$comment');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Delete wireless security profile
  Future<bool> deleteWirelessSecurityProfile(String id) async {
    final result = await sendCommand(['/interface/wireless/security-profiles/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }
}