import 'dart:async';
import 'dart:math';

import '../../../../core/config/app_config.dart';
import 'snmp_data_source.dart';
import '../models/cisco_device_info_model.dart';
import '../models/microsoft_device_info_model.dart';
import '../models/asterisk_device_info_model.dart' as asterisk;

/// A lightweight fake that simulates SNMP responses for testing and development.
///
/// Key features:
/// - Profiles: mikrotik, cisco, microsoft, asterisk, generic
/// - Interface generation with status, speed, mac, counters
/// - Error injection (auth, network, timeout)
/// - Cancellation support via `cancelCurrentOperation()`
/// - Configurable delays and deterministic mode
class FakeSnmpDataSource extends SnmpDataSource {
  bool _cancelled = false;
  final Random _rng;
  final int? minDelayMs;
  final int? maxDelayMs;

  FakeSnmpDataSource({int? seed, this.minDelayMs, this.maxDelayMs}) : _rng = AppConfig.fakeUseDeterministicData ? Random(seed ?? 42) : Random();

  @override
  void cancelCurrentOperation() {
    _cancelled = true;
    super.cancelCurrentOperation();
  }

  @override
  Future<Map<String, dynamic>> fetchDeviceInfo(
    String ip,
    String community,
    int port,
  ) async {
    _cancelled = false;

    await _maybeDelay();

    _maybeThrowRandomError();

    if (_cancelled) throw CancelledException();

    final profile = _profileFromIp(ip);

    final deviceData = <String, dynamic>{
      'sysName': '${profile.name}-${ip.split('.').last}',
      'sysDescr': profile.sysDescr,
      'sysLocation': 'Data Center Rack ${_rng.nextInt(30) + 1}',
      'sysContact': 'admin@localhost',
      'sysUpTime': '${_rng.nextInt(1000000)}',
      'sysObjectID': profile.sysObjectId,
    };

    return deviceData;
  }

  @override
  Future<Map<int, Map<String, dynamic>>> fetchInterfacesData(
      String ip, String community, int port) async {
    _cancelled = false;
    await _maybeDelay();
    _maybeThrowRandomError();
    if (_cancelled) throw CancelledException();

    final profile = _profileFromIp(ip);
    final count = profile.interfaceCount ?? AppConfig.fakeDefaultInterfaceCount;

    final data = <int, Map<String, dynamic>>{};

    for (int i = 1; i <= count; i++) {
      if (_cancelled) throw CancelledException();

      // Small per-interface delay to simulate batching
      if (i % 5 == 0) await Future.delayed(const Duration(milliseconds: 20));

      final name = profile.interfaceName(i);
      final admin = _rng.nextBool() ? 1 : 2; // 1 up, 2 down
      final oper = admin == 1 ? ( _rng.nextDouble() > 0.1 ? 1 : 2) : 2;

      data[i] = {
        'name': name,
        'adminStatus': admin.toString(),
        'operStatus': oper.toString(),
        'speed': ([_rng.nextInt(1000000000), 100000000, 10000000]..shuffle(_rng)).first.toString(),
        'physAddress': _generateMac(i),
        'lastChange': '${_rng.nextInt(100000)}',
        'inOctets': '${_rng.nextInt(10000000)}',
        'outOctets': '${_rng.nextInt(10000000)}',
        'inErrors': '${_rng.nextInt(100)}',
        'outErrors': '${_rng.nextInt(100)}',
        'vlanId': profile.maybeVlanForIndex(i),
        'duplex': ([_rng.nextInt(4), 2, 3]..shuffle(_rng)).first.toString(),
        // vendor-specific
        'poeEnabled': profile == _Profiles.cisco ? (_rng.nextBool() ? '1' : '0') : null,
      }..removeWhere((k, v) => v == null);
    }

    return data;
  }

  // Vendor-specific fetchers used by vendor usecases. Return minimal models for tests.
  @override
  Future<CiscoDeviceInfoModel?> fetchCiscoDeviceInfo(String ip, String community, int port) async {
    final profile = _profileFromIp(ip);
    await _maybeDelay();
    if (profile == _Profiles.cisco) {
      return CiscoDeviceInfoModel(
        modelName: 'C9500',
        serialNumber: 'SN123456',
        iosVersion: '17.3',
        cpuUsage5sec: _rng.nextInt(50),
      );
    }
    return null;
  }

  @override
  Future<MicrosoftDeviceInfoModel?> fetchMicrosoftDeviceInfo(String ip, String community, int port) async {
    final profile = _profileFromIp(ip);
    await _maybeDelay();
    if (profile == _Profiles.microsoft) {
      return MicrosoftDeviceInfoModel(osVersion: 'Windows Server 2019');
    }
    return null;
  }

  @override
  Future<asterisk.AsteriskDeviceInfoModel?> fetchAsteriskDeviceInfo(String ip, String community, int port) async {
    final profile = _profileFromIp(ip);
    await _maybeDelay();
    if (profile == _Profiles.asterisk) {
      return asterisk.AsteriskDeviceInfoModel(osVersion: '18.0');
    }
    return null;
  }

  Future<void> _maybeDelay() async {
    final min = minDelayMs ?? AppConfig.fakeMinDelay.inMilliseconds;
    final max = maxDelayMs ?? AppConfig.fakeMaxDelay.inMilliseconds;
    final ms = min + _rng.nextInt((max - min) + 1);
    await Future.delayed(Duration(milliseconds: ms));
  }

  void _maybeThrowRandomError() {
    final chance = AppConfig.fakeErrorRate;
    if (chance > 0 && _rng.nextDouble() < chance) {
      final pick = _rng.nextInt(3);
      if (pick == 0) throw SnmpAuthenticationException('Invalid community string');
      if (pick == 1) throw NetworkException('Simulated network failure');
      throw TimeoutException('Simulated timeout');
    }
  }

  String _generateMac(int i) {
    final parts = List.generate(6, (idx) => _rng.nextInt(256));
    // make it deterministic per-index a bit
    parts[5] = (parts[5] + i) & 0xff;
    return parts.map((p) => p.toRadixString(16).padLeft(2, '0')).join(':');
  }

  _Profiles _profileFromIp(String ip) {
    // Simple heuristic: last octet mod something
    final last = int.tryParse(ip.split('.').last) ?? 0;
    final pick = last % 5;
    return _Profiles.values[pick];
  }
}

/// Internal profiles with associated behavior
enum _Profiles { mikrotik, cisco, microsoft, asterisk, generic }

extension _ProfileExt on _Profiles {
  String get name {
    switch (this) {
      case _Profiles.cisco:
        return 'cisco';
      case _Profiles.mikrotik:
        return 'mikrotik';
      case _Profiles.microsoft:
        return 'microsoft';
      case _Profiles.asterisk:
        return 'asterisk';
      case _Profiles.generic:
        return 'generic';
    }
  }

  String get sysDescr {
    switch (this) {
      case _Profiles.cisco:
        return 'Cisco IOS Software, C9500';
      case _Profiles.mikrotik:
        return 'MikroTik RouterOS';
      case _Profiles.microsoft:
        return 'Microsoft Windows Server';
      case _Profiles.asterisk:
        return 'Asterisk PBX';
      case _Profiles.generic:
        return 'Generic SNMP Device';
    }
  }

  String get sysObjectId {
    switch (this) {
      case _Profiles.cisco:
        return '1.3.6.1.4.1.9';
      case _Profiles.mikrotik:
        return '1.3.6.1.4.1.14988';
      case _Profiles.microsoft:
        return '1.3.6.1.4.1.311';
      case _Profiles.asterisk:
        return '1.3.6.1.4.1.22736';
      case _Profiles.generic:
        return '1.3.6.1.4.1.99999';
    }
  }

  int? get interfaceCount {
    switch (this) {
      case _Profiles.cisco:
        return 24;
      case _Profiles.asterisk:
        return 8;
      case _Profiles.mikrotik:
        return 12;
      case _Profiles.microsoft:
        return 4;
      case _Profiles.generic:
        return null;
    }
  }

  String interfaceName(int index) {
    if (this == _Profiles.cisco) return 'Gi1/0/$index';
    if (this == _Profiles.mikrotik) return 'ether$index';
    if (this == _Profiles.asterisk) return 'PJSIP/$index';
    if (this == _Profiles.microsoft) return 'Ethernet $index';
    return 'if$index';
  }

  String? maybeVlanForIndex(int index) {
    if (this == _Profiles.cisco && (index % 5 == 0)) return '${100 + (index % 5)}';
    if (this == _Profiles.mikrotik && index % 8 == 0) return '${200 + (index % 8)}';
    return null;
  }
}


