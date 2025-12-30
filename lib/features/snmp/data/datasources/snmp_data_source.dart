// lib/data/data_sources/snmp_data_source.dart

import 'dart:async';
import 'dart:io';
import 'package:dart_snmp/dart_snmp.dart';
import 'package:flutter/foundation.dart';
import 'oid_constants.dart';
import '../models/cisco_device_info_model.dart';
import '../models/microsoft_device_info_model.dart';
import '../models/asterisk_device_info_model.dart' as asterisk;

// Custom Exception Classes
class CancelledException implements Exception {
  final String message = 'SNMP operation cancelled.';
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class NoDataFetchedException implements Exception {
  final String message;
  NoDataFetchedException(this.message);
  @override
  String toString() => 'NoDataFetchedException: $message';
}

class SnmpAuthenticationException implements Exception {
  final String message;
  SnmpAuthenticationException(this.message);
  @override
  String toString() => 'SnmpAuthenticationException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}

// Enum to represent different device vendors
enum DeviceVendor { cisco, mikrotik, microsoft, asterisk, unknown }

class SnmpDataSource {
  // Private member to track active session
  static Snmp? _activeSession;
  static int _sessionRefCount = 0;

  bool _isCancelled = false;

  Future<Map<String, dynamic>> fetchDeviceInfo(
    String ip,
    String community,
    int port,
  ) async {
    debugPrint('DataSource: Starting fetchDeviceInfo. IP: $ip');
    _isCancelled = false;
    final deviceData = <String, dynamic>{};

    try {
      final target = InternetAddress(ip);
      final session = await _getOrCreateSession(target, community, port);

      final sysOids = {
        'sysDescr': OidConstants.sysDescr,
        'sysObjectID': OidConstants.sysObjectId,
        'sysUpTime': OidConstants.sysUpTime,
        'sysContact': OidConstants.sysContact,
        'sysName': OidConstants.sysName,
        'sysLocation': OidConstants.sysLocation,
      };

      for (final entry in sysOids.entries) {
        if (_isCancelled) throw CancelledException();

        try {
          final oid = Oid.fromString(entry.value);
          final result = await session.get(oid).timeout(
                const Duration(seconds: 2),
                onTimeout: () =>
                    throw TimeoutException('Timeout fetching ${entry.key}'),
              );

          if (result.pdu.error == PduError.noError &&
              result.pdu.varbinds.isNotEmpty) {
            final value = result.pdu.varbinds[0].value;
            if (value != null && !value.toString().startsWith('ASN1Object')) {
              deviceData[entry.key] = value.toString();
            }
          }
        } catch (e) {
          if (e is TimeoutException && entry.key == 'sysDescr') {
            throw SnmpAuthenticationException(
                'Cannot retrieve basic device info. Check community string.');
          }
          debugPrint('Warning: Could not fetch ${entry.key}: $e');
        }
      }

      if (deviceData.isEmpty) {
        throw NoDataFetchedException(
            'No device information could be retrieved');
      }
    } on SocketException catch (e) {
      debugPrint('DataSource: SocketException during device info fetch: $e');
      throw NetworkException('Socket error: ${e.message}');
    } on TimeoutException {
      rethrow;
    } on CancelledException {
      rethrow;
    } on SnmpAuthenticationException {
      rethrow;
    } catch (e) {
      debugPrint(
          'DataSource: Unhandled exception during device info fetch: $e');
      throw NetworkException('An unknown error occurred: ${e.toString()}');
    } finally {
      _releaseSession();
      _isCancelled = false;
    }

    return deviceData;
  }

  Future<Map<int, Map<String, dynamic>>> fetchInterfacesData(
      String ip, String community, int port) async {
    debugPrint('DataSource: Starting optimized interface data fetch. IP: $ip');
    _isCancelled = false;
    final interfaceData = <int, Map<String, dynamic>>{};

    try {
      final target = InternetAddress(ip);
      final session = await _getOrCreateSession(target, community, port);
      debugPrint('DataSource: Using SNMP session.');

      // ** Detect vendor for specific logic **
      final vendor = await _detectVendor(session);

      // Get number of interfaces
      int maxInterfaces = 100;
      try {
        final ifNumberOid = Oid.fromString(OidConstants.ifNumber);
        final ifNumberResult =
            await session.get(ifNumberOid).timeout(const Duration(seconds: 2));
        if (ifNumberResult.pdu.error == PduError.noError &&
            ifNumberResult.pdu.varbinds.isNotEmpty) {
          maxInterfaces =
              int.tryParse(ifNumberResult.pdu.varbinds[0].value.toString()) ??
                  100;
          debugPrint(
              'Device reports $maxInterfaces interfaces. Vendor: ${vendor.name}');
        }
      } catch (e) {
        debugPrint('Could not get ifNumber, using default range');
      }

      // Fetch interfaces in intelligent batches
      const batchSize = 5;
      final searchLimit = maxInterfaces > 200 ? 200 : maxInterfaces + 10;

      for (int startIdx = 1; startIdx <= searchLimit; startIdx += batchSize) {
        if (_isCancelled) throw CancelledException();

        final endIdx = (startIdx + batchSize - 1) > searchLimit
            ? searchLimit
            : (startIdx + batchSize - 1);
        final batchFutures = <Future<MapEntry<int, Map<String, dynamic>?>>>[];

        // Check batch in parallel
        for (int idx = startIdx; idx <= endIdx; idx++) {
          batchFutures.add(_fetchInterfaceData(session, idx, vendor));
        }

        final batchResults = await Future.wait(batchFutures);

        // Process results
        int emptyCount = 0;
        for (final result in batchResults) {
          if (result.value != null && result.value!.isNotEmpty) {
            interfaceData[result.key] = result.value!;
          } else {
            emptyCount++;
          }
        }

        if (emptyCount == batchSize && interfaceData.isNotEmpty) {
          debugPrint('Reached end of interfaces');
          break;
        }
      }

      if (!_isCancelled && interfaceData.isEmpty) {
        throw NoDataFetchedException(
            'No interface data received. Check SNMP settings.');
      }

      debugPrint('DataSource: Found ${interfaceData.length} interfaces total');
    } on SocketException catch (e) {
      throw NetworkException('Socket error: ${e.message}');
    } on TimeoutException {
      throw TimeoutException('SNMP operation timed out.');
    } on CancelledException {
      rethrow;
    } on NoDataFetchedException {
      rethrow;
    } catch (e) {
      throw NetworkException('Unknown error: ${e.toString()}');
    } finally {
      await _closeSession();
      _isCancelled = false;
      debugPrint('DataSource: SNMP session closed.');
    }

    return interfaceData;
  }

  Future<DeviceVendor> _detectVendor(Snmp session) async {
    try {
      final oid = Oid.fromString(OidConstants.sysObjectId);
      final result = await session.get(oid).timeout(const Duration(seconds: 2));
      if (result.pdu.error == PduError.noError &&
          result.pdu.varbinds.isNotEmpty) {
        final objectId = result.pdu.varbinds[0].value.toString();
        if (objectId.startsWith(OidConstants.ciscoEnterpriseId)) {
          return DeviceVendor.cisco;
        }
        if (objectId.startsWith(OidConstants.mikrotikEnterpriseId)) {
          return DeviceVendor.mikrotik;
        }
        if (objectId.startsWith(OidConstants.asteriskEnterpriseId)) {
          return DeviceVendor.asterisk;
        }
      }
      
      // Try to detect by sysDescr for Windows/Microsoft
      final descrOid = Oid.fromString(OidConstants.sysDescr);
      final descrResult = await session.get(descrOid).timeout(const Duration(seconds: 2));
      if (descrResult.pdu.error == PduError.noError &&
          descrResult.pdu.varbinds.isNotEmpty) {
        final descr = descrResult.pdu.varbinds[0].value.toString().toLowerCase();
        if (descr.contains('windows') || descr.contains('microsoft')) {
          return DeviceVendor.microsoft;
        }
        if (descr.contains('asterisk') || descr.contains('linux') && descr.contains('pbx')) {
          return DeviceVendor.asterisk;
        }
      }
    } catch (e) {
      debugPrint('Could not detect vendor from sysObjectID: $e');
    }
    return DeviceVendor.unknown;
  }

  // Helper to get or create a single session with ref counting
  Future<Snmp> _getOrCreateSession(
    InternetAddress target,
    String community,
    int port,
  ) async {
    if (_activeSession != null) {
      _sessionRefCount++;
      return _activeSession!;
    }

    _activeSession = await Snmp.createSession(
      target,
      community: community,
      port: port,
      timeout: const Duration(seconds: 3),
      retries: 1,
    );
    _sessionRefCount = 1;

    return _activeSession!;
  }

  // Release session reference
  void _releaseSession() {
    if (_activeSession != null && _sessionRefCount > 0) {
      _sessionRefCount--;
    }
  }

  // Close session when all refs are released
  Future<void> _closeSession() async {
    if (_activeSession != null && _sessionRefCount <= 1) {
      try {
        _activeSession?.close();
      } catch (e) {
        debugPrint('Error closing session: $e');
      } finally {
        _activeSession = null;
        _sessionRefCount = 0;
      }
    } else {
      _releaseSession();
    }
  }

  // Fetch complete interface data including VLAN info
  Future<MapEntry<int, Map<String, dynamic>?>> _fetchInterfaceData(
      Snmp session, int index, DeviceVendor vendor) async {
    try {
      final nameOid = Oid.fromString('${OidConstants.ifDescrBase}$index');
      final result =
          await session.get(nameOid).timeout(const Duration(milliseconds: 800));

      if (result.pdu.error == PduError.noSuchName ||
          result.pdu.varbinds.isEmpty ||
          result.pdu.varbinds[0].value == null) {
        return MapEntry(index, null);
      }

      final name = result.pdu.varbinds[0].value.toString();
      if (name.isEmpty || name.startsWith('ASN1Object')) {
        return MapEntry(index, null);
      }

      final data = <String, dynamic>{'name': name};

      final oidsToFetch = [
        MapEntry('adminStatus', '${OidConstants.ifAdminStatusBase}$index'),
        MapEntry('operStatus', '${OidConstants.ifOperStatusBase}$index'),
        MapEntry('type', '${OidConstants.ifTypeBase}$index'),
        MapEntry('speed', '${OidConstants.ifSpeedBase}$index'),
        MapEntry('physAddress', '${OidConstants.ifPhysAddressBase}$index'),
        MapEntry('lastChange', '${OidConstants.ifLastChangeBase}$index'),
        MapEntry('inOctets', '${OidConstants.ifInOctetsBase}$index'),
        MapEntry('outOctets', '${OidConstants.ifOutOctetsBase}$index'),
        MapEntry('inErrors', '${OidConstants.ifInErrorsBase}$index'),
        MapEntry('outErrors', '${OidConstants.ifOutErrorsBase}$index'),
        MapEntry('ifName', '${OidConstants.ifNameBase}$index'),
        MapEntry('ifAlias', '${OidConstants.ifAliasBase}$index'),
        MapEntry('vlanId', '${OidConstants.dot1qPvid}$index'),
      ];

      // ** Add vendor-specific OIDs **
      if (vendor == DeviceVendor.cisco) {
        oidsToFetch
            .add(MapEntry('ciscoVlanId', '${OidConstants.ciscoVmVlan}$index'));
        // Add PoE information for Cisco devices
        oidsToFetch.add(MapEntry(
            'poeEnabled', '${OidConstants.cpeExtPsePortEnable}$index'));
        oidsToFetch.add(MapEntry('poePowerAllocated',
            '${OidConstants.cpeExtPsePortPwrAllocated}$index'));
        oidsToFetch.add(MapEntry('poePowerConsumption',
            '${OidConstants.cpeExtPsePortPwrConsumption}$index'));
        // Add Duplex information
        oidsToFetch.add(
            MapEntry('duplex', '${OidConstants.dot3StatsDuplexStatus}$index'));
      }

      final futures = oidsToFetch
          .map((e) => _getSingleOid(session, e.value)
              .then((v) => v != null ? MapEntry(e.key, v) : null))
          .toList();

      final results = await Future.wait(futures);
      for (final result in results) {
        if (result != null) {
          data[result.key] = result.value;
        }
      }

      // Smart VLAN detection
      if (vendor == DeviceVendor.cisco && data['ciscoVlanId'] != null) {
        data['vlanId'] = data['ciscoVlanId'];
      } else if (name.toLowerCase().contains('vlan') &&
          data['vlanId'] == null) {
        final vlanMatch =
            RegExp(r'vlan\s*(\d+)', caseSensitive: false).firstMatch(name);
        if (vlanMatch != null) {
          data['vlanId'] = vlanMatch.group(1);
        }
      }

      return MapEntry(index, data);
    } catch (e) {
      return MapEntry(index, null);
    }
  }

  // Get single OID value
  Future<String?> _getSingleOid(Snmp session, String oidString) async {
    try {
      final oid = Oid.fromString(oidString);
      final result =
          await session.get(oid).timeout(const Duration(milliseconds: 500));

      if (result.pdu.error == PduError.noError &&
          result.pdu.varbinds.isNotEmpty) {
        final value = result.pdu.varbinds[0].value;
        if (value != null && !value.toString().startsWith('ASN1Object')) {
          return value.toString();
        }
      }
    } catch (_) {
      // Ignore errors for optional OIDs
    }
    return null;
  }

  void cancelCurrentOperation() {
    debugPrint('DataSource: Cancellation requested.');
    _isCancelled = true;
    _closeSession();
  }

  /// Fetch Cisco-specific device information
  Future<CiscoDeviceInfoModel?> fetchCiscoDeviceInfo(
    String ip,
    String community,
    int port,
  ) async {
    debugPrint('DataSource: Starting Cisco device info fetch. IP: $ip');
    _isCancelled = false;

    try {
      final target = InternetAddress(ip);
      final session = await _getOrCreateSession(target, community, port);

      // Check if it's actually a Cisco device
      final vendor = await _detectVendor(session);
      if (vendor != DeviceVendor.cisco) {
        debugPrint('DataSource: Device is not Cisco, skipping Cisco-specific info');
        return null;
      }

      // Fetch all Cisco-specific information in parallel
      final results = await Future.wait([
        _fetchCiscoHardwareInfo(session),
        _fetchCiscoCpuUsage(session),
        _fetchCiscoMemoryUsage(session),
        _fetchCiscoEnvironmentalStatus(session),
      ]);

      final hardwareInfo = results[0] as Map<String, dynamic>?;
      final cpuInfo = results[1] as Map<String, dynamic>?;
      final memoryInfo = results[2] as Map<String, dynamic>?;
      final envInfo = results[3] as EnvironmentalStatus?;

      return CiscoDeviceInfoModel(
        modelName: hardwareInfo?['modelName'],
        serialNumber: hardwareInfo?['serialNumber'],
        iosVersion: hardwareInfo?['iosVersion'],
        hardwareVersion: hardwareInfo?['hardwareVersion'],
        description: hardwareInfo?['description'],
        cpuUsage5sec: cpuInfo?['cpu5sec'],
        cpuUsage1min: cpuInfo?['cpu1min'],
        cpuUsage5min: cpuInfo?['cpu5min'],
        memoryUsed: memoryInfo?['used'],
        memoryFree: memoryInfo?['free'],
        memoryTotal: memoryInfo?['total'],
        memoryUtilization: memoryInfo?['utilization'],
        environmental: envInfo,
      );
    } on SocketException catch (e) {
      debugPrint('DataSource: SocketException during Cisco info fetch: $e');
      throw NetworkException('Socket error: ${e.message}');
    } catch (e) {
      debugPrint('DataSource: Error fetching Cisco info: $e');
      return null;
    } finally {
      _releaseSession();
      _isCancelled = false;
    }
  }

  /// Fetch hardware information
  Future<Map<String, dynamic>?> _fetchCiscoHardwareInfo(Snmp session) async {
    try {
      final results = await Future.wait([
        _getSingleOid(session, OidConstants.entPhysicalModelName),
        _getSingleOid(session, OidConstants.entPhysicalSerialNum),
        _getSingleOid(session, OidConstants.entPhysicalSoftwareRev),
        _getSingleOid(session, OidConstants.entPhysicalHardwareRev),
        _getSingleOid(session, OidConstants.entPhysicalDescr),
      ]);

      return {
        'modelName': results[0],
        'serialNumber': results[1],
        'iosVersion': results[2],
        'hardwareVersion': results[3],
        'description': results[4],
      };
    } catch (e) {
      debugPrint('Error fetching Cisco hardware info: $e');
      return null;
    }
  }

  /// Fetch CPU usage information
  Future<Map<String, dynamic>?> _fetchCiscoCpuUsage(Snmp session) async {
    try {
      final results = await Future.wait([
        _getSingleOid(session, OidConstants.cpmCPUTotal5sec),
        _getSingleOid(session, OidConstants.cpmCPUTotal1min),
        _getSingleOid(session, OidConstants.cpmCPUTotal5min),
      ]);

      return {
        'cpu5sec': results[0] != null ? int.tryParse(results[0]!) : null,
        'cpu1min': results[1] != null ? int.tryParse(results[1]!) : null,
        'cpu5min': results[2] != null ? int.tryParse(results[2]!) : null,
      };
    } catch (e) {
      debugPrint('Error fetching Cisco CPU usage: $e');
      return null;
    }
  }

  /// Fetch memory usage information
  Future<Map<String, dynamic>?> _fetchCiscoMemoryUsage(Snmp session) async {
    try {
      final results = await Future.wait([
        _getSingleOid(session, OidConstants.ciscoMemoryPoolUsed),
        _getSingleOid(session, OidConstants.ciscoMemoryPoolFree),
      ]);

      final used = results[0] != null ? int.tryParse(results[0]!) : null;
      final free = results[1] != null ? int.tryParse(results[1]!) : null;

      int? total;
      double? utilization;
      if (used != null && free != null) {
        total = used + free;
        utilization = total > 0 ? (used / total * 100) : 0;
      }

      return {
        'used': used,
        'free': free,
        'total': total,
        'utilization': utilization,
      };
    } catch (e) {
      debugPrint('Error fetching Cisco memory usage: $e');
      return null;
    }
  }

  /// Fetch environmental status (temperature, fans, power supplies)
  Future<EnvironmentalStatus?> _fetchCiscoEnvironmentalStatus(
      Snmp session) async {
    try {
      final results = await Future.wait([
        _fetchTemperatureInfo(session),
        _fetchFanInfo(session),
        _fetchPowerSupplyInfo(session),
      ]);

      return EnvironmentalStatus(
        temperature: results[0] as TemperatureInfo?,
        fans: results[1] as List<FanInfo>?,
        powerSupplies: results[2] as List<PowerSupplyInfo>?,
      );
    } catch (e) {
      debugPrint('Error fetching Cisco environmental status: $e');
      return null;
    }
  }

  /// Fetch temperature sensor information
  Future<TemperatureInfo?> _fetchTemperatureInfo(Snmp session) async {
    try {
      final results = await Future.wait([
        _getSingleOid(session, OidConstants.ciscoEnvMonTemperatureStatusDescr),
        _getSingleOid(session, OidConstants.ciscoEnvMonTemperatureStatusValue),
        _getSingleOid(session, OidConstants.ciscoEnvMonTemperatureState),
      ]);

      if (results[0] == null && results[1] == null) return null;

      return TemperatureInfo(
        description: results[0],
        value: results[1] != null ? int.tryParse(results[1]!) : null,
        state: _parseEnvMonState(results[2]),
      );
    } catch (e) {
      debugPrint('Error fetching temperature info: $e');
      return null;
    }
  }

  /// Fetch fan status information
  Future<List<FanInfo>?> _fetchFanInfo(Snmp session) async {
    try {
      final descr =
          await _getSingleOid(session, OidConstants.ciscoEnvMonFanStatusDescr);
      final state =
          await _getSingleOid(session, OidConstants.ciscoEnvMonFanState);

      if (descr == null && state == null) return null;

      return [
        FanInfo(
          description: descr,
          state: _parseEnvMonState(state),
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching fan info: $e');
      return null;
    }
  }

  /// Fetch power supply status information
  Future<List<PowerSupplyInfo>?> _fetchPowerSupplyInfo(Snmp session) async {
    try {
      final results = await Future.wait([
        _getSingleOid(session, OidConstants.ciscoEnvMonSupplyStatusDescr),
        _getSingleOid(session, OidConstants.ciscoEnvMonSupplyState),
        _getSingleOid(session, OidConstants.ciscoEnvMonSupplySource),
      ]);

      if (results[0] == null && results[1] == null) return null;

      return [
        PowerSupplyInfo(
          description: results[0],
          state: _parseEnvMonState(results[1]),
          source: _parsePowerSource(results[2]),
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching power supply info: $e');
      return null;
    }
  }

  /// Parse environmental monitor state
  String? _parseEnvMonState(String? value) {
    if (value == null) return null;
    final state = int.tryParse(value);
    if (state == null) return null;

    switch (state) {
      case 1:
        return 'normal';
      case 2:
        return 'warning';
      case 3:
        return 'critical';
      case 4:
        return 'shutdown';
      case 5:
        return 'notPresent';
      case 6:
        return 'notFunctioning';
      default:
        return 'unknown';
    }
  }

  /// Parse power source
  String? _parsePowerSource(String? value) {
    if (value == null) return null;
    final source = int.tryParse(value);
    if (source == null) return null;

    switch (source) {
      case 1:
        return 'unknown';
      case 2:
        return 'ac';
      case 3:
        return 'dc';
      case 4:
        return 'externalPowerSupply';
      case 5:
        return 'internalRedundant';
      default:
        return 'unknown';
    }
  }

  /// Fetch PoE information for a specific interface
  Future<PoePortInfo?> fetchPoePortInfo(
    String ip,
    String community,
    int port,
    int interfaceIndex,
  ) async {
    try {
      final target = InternetAddress(ip);
      final session = await _getOrCreateSession(target, community, port);

      final results = await Future.wait([
        _getSingleOid(
            session, '${OidConstants.cpeExtPsePortEnable}$interfaceIndex'),
        _getSingleOid(session,
            '${OidConstants.cpeExtPsePortPwrAllocated}$interfaceIndex'),
        _getSingleOid(session,
            '${OidConstants.cpeExtPsePortPwrAvailable}$interfaceIndex'),
        _getSingleOid(session,
            '${OidConstants.cpeExtPsePortPwrConsumption}$interfaceIndex'),
      ]);

      if (results.every((r) => r == null)) return null;

      return PoePortInfo(
        enabled: results[0] == '1',
        powerAllocated: results[1] != null ? int.tryParse(results[1]!) : null,
        powerAvailable: results[2] != null ? int.tryParse(results[2]!) : null,
        powerConsumption:
            results[3] != null ? int.tryParse(results[3]!) : null,
      );
    } catch (e) {
      debugPrint('Error fetching PoE port info: $e');
      return null;
    } finally {
      _releaseSession();
    }
  }

  // ============================================================
  // Microsoft Windows Device Info Methods (HOST-RESOURCES-MIB)
  // ============================================================

  Future<MicrosoftDeviceInfoModel?> fetchMicrosoftDeviceInfo(
    String ip,
    String community,
    int port,
  ) async {
    debugPrint('DataSource: Starting Microsoft device info fetch. IP: $ip');
    _isCancelled = false;

    try {
      final target = InternetAddress(ip);
      final session = await _getOrCreateSession(target, community, port);

      // Check if device is Microsoft
      final vendor = await _detectVendor(session);
      if (vendor != DeviceVendor.microsoft) {
        debugPrint(
            'DataSource: Device is not Microsoft, skipping Microsoft-specific info');
        return null;
      }

      // Fetch all information in parallel
      final results = await Future.wait([
        _fetchHostResourcesSystemInfo(session),
        _fetchHostResourcesProcessors(session),
        _fetchHostResourcesStorage(session),
        _fetchHostResourcesServices(session, limit: 20), // Top 20 services
      ]);

      final systemInfo = results[0] as Map<String, dynamic>?;
      final processors = results[1] as List<ProcessorInfo>?;
      final storages = results[2] as List<StorageInfo>?;
      final services = results[3] as List<ServiceInfo>?;

      // Parse memory from storage table
      final memoryInfo = _parseMemoryFromStorage(storages);

      return MicrosoftDeviceInfoModel(
        osVersion: systemInfo?['osVersion'],
        uptimeSeconds: systemInfo?['uptimeSeconds'],
        numUsers: systemInfo?['numUsers'],
        numProcesses: systemInfo?['numProcesses'],
        maxProcesses: systemInfo?['maxProcesses'],
        processors: processors,
        physicalMemoryTotal: memoryInfo['physicalTotal'],
        physicalMemoryUsed: memoryInfo['physicalUsed'],
        virtualMemoryTotal: memoryInfo['virtualTotal'],
        virtualMemoryUsed: memoryInfo['virtualUsed'],
        storages: storages,
        services: services,
      );
    } on SocketException catch (e) {
      debugPrint('DataSource: SocketException during Microsoft info fetch: $e');
      throw NetworkException('Socket error: ${e.message}');
    } catch (e) {
      debugPrint('DataSource: Error fetching Microsoft info: $e');
      return null;
    } finally {
      _releaseSession();
      _isCancelled = false;
    }
  }

  // ============================================================
  // Asterisk PBX Device Info Methods (HOST-RESOURCES-MIB)
  // ============================================================

  Future<asterisk.AsteriskDeviceInfoModel?> fetchAsteriskDeviceInfo(
    String ip,
    String community,
    int port,
  ) async {
    debugPrint('DataSource: Starting Asterisk device info fetch. IP: $ip');
    _isCancelled = false;

    try {
      final target = InternetAddress(ip);
      final session = await _getOrCreateSession(target, community, port);

      // Check if device is Asterisk
      final vendor = await _detectVendor(session);
      if (vendor != DeviceVendor.asterisk) {
        debugPrint(
            'DataSource: Device is not Asterisk, skipping Asterisk-specific info');
        return null;
      }

      // Fetch all information in parallel
      final results = await Future.wait([
        _fetchHostResourcesSystemInfo(session),
        _fetchHostResourcesProcessors(session),
        _fetchHostResourcesStorage(session),
        _fetchAsteriskProcess(session),
      ]);

      final systemInfo = results[0] as Map<String, dynamic>?;
      final processors = results[1] as List<asterisk.ProcessorInfo>?;
      final storages = results[2] as List<asterisk.StorageInfo>?;
      final asteriskProcess = results[3] as asterisk.AsteriskProcessInfo?;

      // Parse memory from storage table
      final memoryInfo = _parseMemoryFromStorageForAsterisk(storages);

      return asterisk.AsteriskDeviceInfoModel(
        osVersion: systemInfo?['osVersion'],
        uptimeSeconds: systemInfo?['uptimeSeconds'],
        numUsers: systemInfo?['numUsers'],
        numProcesses: systemInfo?['numProcesses'],
        processors: processors,
        physicalMemoryTotal: memoryInfo['physicalTotal'],
        physicalMemoryUsed: memoryInfo['physicalUsed'],
        virtualMemoryTotal: memoryInfo['virtualTotal'],
        virtualMemoryUsed: memoryInfo['virtualUsed'],
        storages: storages,
        asteriskProcess: asteriskProcess,
      );
    } on SocketException catch (e) {
      debugPrint('DataSource: SocketException during Asterisk info fetch: $e');
      throw NetworkException('Socket error: ${e.message}');
    } catch (e) {
      debugPrint('DataSource: Error fetching Asterisk info: $e');
      return null;
    } finally {
      _releaseSession();
      _isCancelled = false;
    }
  }

  // ============================================================
  // HOST-RESOURCES-MIB Helper Methods (Shared)
  // ============================================================

  /// Fetch system information from HOST-RESOURCES-MIB
  Future<Map<String, dynamic>?> _fetchHostResourcesSystemInfo(
      Snmp session) async {
    try {
      final results = await Future.wait([
        _getSingleOid(session, OidConstants.sysDescr),
        _getSingleOid(session, OidConstants.hrSystemUptime),
        _getSingleOid(session, OidConstants.hrSystemNumUsers),
        _getSingleOid(session, OidConstants.hrSystemProcesses),
        _getSingleOid(session, OidConstants.hrSystemMaxProcesses),
      ]);

      return {
        'osVersion': results[0],
        'uptimeSeconds': results[1] != null
            ? int.tryParse(results[1]!)?.toInt() ?? 0
            : null,
        'numUsers': results[2] != null ? int.tryParse(results[2]!) : null,
        'numProcesses': results[3] != null ? int.tryParse(results[3]!) : null,
        'maxProcesses': results[4] != null ? int.tryParse(results[4]!) : null,
      };
    } catch (e) {
      debugPrint('Error fetching HOST-RESOURCES system info: $e');
      return null;
    }
  }

  /// Fetch processor information from hrProcessorTable
  Future<List<ProcessorInfo>?> _fetchHostResourcesProcessors(
      Snmp session) async {
    try {
      final processors = <ProcessorInfo>[];

      // Try to fetch up to 16 processors
      for (int i = 1; i <= 16; i++) {
        if (_isCancelled) throw CancelledException();

        final results = await Future.wait([
          _getSingleOid(session, '${OidConstants.hrDeviceDescr}$i'),
          _getSingleOid(session, '${OidConstants.hrProcessorLoad}$i'),
        ]);

        // If no description, assume no more processors
        if (results[0] == null) break;

        processors.add(ProcessorInfo(
          index: i,
          description: results[0],
          load: results[1] != null ? int.tryParse(results[1]!) : null,
        ));
      }

      return processors.isEmpty ? null : processors;
    } catch (e) {
      debugPrint('Error fetching processors: $e');
      return null;
    }
  }

  /// Fetch storage information from hrStorageTable
  Future<List<StorageInfo>?> _fetchHostResourcesStorage(Snmp session) async {
    try {
      final storages = <StorageInfo>[];

      // Try to fetch up to 50 storage entries
      for (int i = 1; i <= 50; i++) {
        if (_isCancelled) throw CancelledException();

        final results = await Future.wait([
          _getSingleOid(session, '${OidConstants.hrStorageType}$i'),
          _getSingleOid(session, '${OidConstants.hrStorageDescr}$i'),
          _getSingleOid(session, '${OidConstants.hrStorageAllocationUnits}$i'),
          _getSingleOid(session, '${OidConstants.hrStorageSize}$i'),
          _getSingleOid(session, '${OidConstants.hrStorageUsed}$i'),
        ]);

        // If no type, assume no more storage entries
        if (results[0] == null) break;

        storages.add(StorageInfo(
          index: i,
          type: _parseStorageType(results[0]),
          description: results[1],
          allocationUnits:
              results[2] != null ? int.tryParse(results[2]!) : null,
          size: results[3] != null ? int.tryParse(results[3]!) : null,
          used: results[4] != null ? int.tryParse(results[4]!) : null,
        ));
      }

      return storages.isEmpty ? null : storages;
    } catch (e) {
      debugPrint('Error fetching storage: $e');
      return null;
    }
  }

  /// Fetch running services/processes from hrSWRunTable
  Future<List<ServiceInfo>?> _fetchHostResourcesServices(Snmp session,
      {int limit = 20}) async {
    try {
      final services = <ServiceInfo>[];
      int count = 0;

      // Fetch services with a limit
      for (int i = 1; i <= 1000 && count < limit; i++) {
        if (_isCancelled) throw CancelledException();

        final results = await Future.wait([
          _getSingleOid(session, '${OidConstants.hrSWRunName}$i'),
          _getSingleOid(session, '${OidConstants.hrSWRunPath}$i'),
          _getSingleOid(session, '${OidConstants.hrSWRunType}$i'),
          _getSingleOid(session, '${OidConstants.hrSWRunStatus}$i'),
          _getSingleOid(session, '${OidConstants.hrSWRunPerfCPU}$i'),
          _getSingleOid(session, '${OidConstants.hrSWRunPerfMem}$i'),
        ]);

        // If no name, skip this index
        if (results[0] == null) continue;

        services.add(ServiceInfo(
          index: i,
          name: results[0],
          path: results[1],
          type: _parseServiceType(results[2]),
          status: _parseServiceStatus(results[3]),
          cpuTime: results[4] != null ? int.tryParse(results[4]!) : null,
          memoryUsed: results[5] != null ? int.tryParse(results[5]!) : null,
        ));

        count++;
        if (count >= limit) break;
      }

      return services.isEmpty ? null : services;
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return null;
    }
  }

  /// Fetch Asterisk process specifically
  Future<asterisk.AsteriskProcessInfo?> _fetchAsteriskProcess(
      Snmp session) async {
    try {
      // Search for asterisk process in hrSWRunTable
      for (int i = 1; i <= 1000; i++) {
        if (_isCancelled) throw CancelledException();

        final name = await _getSingleOid(session, '${OidConstants.hrSWRunName}$i');
        if (name == null) continue;

        // Check if this is the asterisk process
        if (name.toLowerCase().contains('asterisk')) {
          final results = await Future.wait([
            _getSingleOid(session, '${OidConstants.hrSWRunPath}$i'),
            _getSingleOid(session, '${OidConstants.hrSWRunStatus}$i'),
            _getSingleOid(session, '${OidConstants.hrSWRunPerfCPU}$i'),
            _getSingleOid(session, '${OidConstants.hrSWRunPerfMem}$i'),
          ]);

          return asterisk.AsteriskProcessInfo(
            index: i,
            name: name,
            path: results[0],
            status: _parseServiceStatus(results[1]),
            cpuTime: results[2] != null ? int.tryParse(results[2]!) : null,
            memoryUsed: results[3] != null ? int.tryParse(results[3]!) : null,
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching Asterisk process: $e');
      return null;
    }
  }

  /// Parse memory information from storage table
  Map<String, int?> _parseMemoryFromStorage(List<StorageInfo>? storages) {
    if (storages == null) {
      return {
        'physicalTotal': null,
        'physicalUsed': null,
        'virtualTotal': null,
        'virtualUsed': null,
      };
    }

    int? physicalTotal, physicalUsed, virtualTotal, virtualUsed;

    for (final storage in storages) {
      if (storage.type == 'Physical Memory' || storage.type == 'RAM') {
        physicalTotal = storage.totalBytes;
        physicalUsed = storage.usedBytes;
      } else if (storage.type == 'Virtual Memory') {
        virtualTotal = storage.totalBytes;
        virtualUsed = storage.usedBytes;
      }
    }

    return {
      'physicalTotal': physicalTotal,
      'physicalUsed': physicalUsed,
      'virtualTotal': virtualTotal,
      'virtualUsed': virtualUsed,
    };
  }

  /// Parse memory for Asterisk (same logic, different types)
  Map<String, int?> _parseMemoryFromStorageForAsterisk(
      List<asterisk.StorageInfo>? storages) {
    if (storages == null) {
      return {
        'physicalTotal': null,
        'physicalUsed': null,
        'virtualTotal': null,
        'virtualUsed': null,
      };
    }

    int? physicalTotal, physicalUsed, virtualTotal, virtualUsed;

    for (final storage in storages) {
      if (storage.type == 'Physical Memory' || storage.type == 'RAM') {
        physicalTotal = storage.totalBytes;
        physicalUsed = storage.usedBytes;
      } else if (storage.type == 'Virtual Memory' || storage.type == 'Swap') {
        virtualTotal = storage.totalBytes;
        virtualUsed = storage.usedBytes;
      }
    }

    return {
      'physicalTotal': physicalTotal,
      'physicalUsed': physicalUsed,
      'virtualTotal': virtualTotal,
      'virtualUsed': virtualUsed,
    };
  }

  /// Parse storage type from OID value
  String? _parseStorageType(String? value) {
    if (value == null) return null;
    
    // Storage type OIDs: 1.3.6.1.2.1.25.2.1.x
    if (value.endsWith('.2')) return 'Physical Memory';
    if (value.endsWith('.3')) return 'Virtual Memory';
    if (value.endsWith('.4')) return 'Fixed Disk';
    if (value.endsWith('.5')) return 'Removable Disk';
    if (value.endsWith('.6')) return 'Floppy Disk';
    if (value.endsWith('.7')) return 'Compact Disc';
    if (value.endsWith('.8')) return 'RAM Disk';
    if (value.endsWith('.10')) return 'Network Disk';
    
    return 'Other';
  }

  /// Parse service/process type
  String? _parseServiceType(String? value) {
    if (value == null) return null;
    final type = int.tryParse(value);
    if (type == null) return null;

    switch (type) {
      case 1:
        return 'unknown';
      case 2:
        return 'operatingSystem';
      case 3:
        return 'deviceDriver';
      case 4:
        return 'application';
      default:
        return 'unknown';
    }
  }

  /// Parse service/process status
  String? _parseServiceStatus(String? value) {
    if (value == null) return null;
    final status = int.tryParse(value);
    if (status == null) return null;

    switch (status) {
      case 1:
        return 'running';
      case 2:
        return 'runnable';
      case 3:
        return 'notRunnable';
      case 4:
        return 'invalid';
      default:
        return 'unknown';
    }
  }
}
