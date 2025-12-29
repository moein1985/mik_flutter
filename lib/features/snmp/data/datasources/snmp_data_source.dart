// lib/data/data_sources/snmp_data_source.dart

import 'dart:async';
import 'dart:io';
import 'package:dart_snmp/dart_snmp.dart';
import 'package:flutter/foundation.dart';
import 'oid_constants.dart';

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
enum DeviceVendor { cisco, mikrotik, unknown }

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
}
