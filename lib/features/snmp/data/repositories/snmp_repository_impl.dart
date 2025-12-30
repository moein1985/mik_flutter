import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/snmp_data_source.dart';
import '../../domain/entities/interface_info.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/repositories/snmp_repository.dart';

class SnmpRepositoryImpl implements SnmpRepository {
  final SnmpDataSource remoteDataSource;

  SnmpRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DeviceInfo>> getDeviceInfo(String ip, String community, int port) async {
    try {
      final rawData = await remoteDataSource.fetchDeviceInfo(ip, community, port);
      final deviceInfo = DeviceInfo(
        sysName: rawData['sysName'] as String?,
        sysDescr: rawData['sysDescr'] as String?,
        sysLocation: rawData['sysLocation'] as String?,
        sysContact: rawData['sysContact'] as String?,
        sysUpTime: _formatUptime(rawData['sysUpTime'] as String?),
        sysObjectID: rawData['sysObjectID'] as String?,
      );
      return Right(deviceInfo);
    } on SnmpAuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CancelledException {
      return Left(CancellationFailure());
    } on NoDataFetchedException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unknown error occurred while fetching device info: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InterfaceInfo>>> getInterfaces(String ip, String community, int port) async {
    try {
      final rawData = await remoteDataSource.fetchInterfacesData(ip, community, port);
      final List<InterfaceInfo> interfaces = [];
      rawData.forEach((index, data) {
        interfaces.add(InterfaceInfo(
          index: index,
          name: data['name'] as String? ?? 'N/A',
          rawAdminStatus: data['adminStatus']?.toString() ?? '',
          rawOperStatus: data['operStatus']?.toString() ?? '',
          rawSpeed: data['speed'] as String?,
          rawMacAddress: data['physAddress'] as String?,
          rawType: data['type'] as String?,
          rawLastChange: data['lastChange'] as String?,
          rawInOctets: _parseIntValue(data['inOctets']),
          rawOutOctets: _parseIntValue(data['outOctets']),
          rawInErrors: _parseIntValue(data['inErrors']),
          rawOutErrors: _parseIntValue(data['outErrors']),
          displayAdminStatus: _getDisplayStatus(data['adminStatus']),
          displayOperStatus: _getDisplayStatus(data['operStatus']),
          adminStatusColor: _getStatusColor(data['adminStatus']),
          operStatusColor: _getStatusColor(data['operStatus']),
          adminStatusIcon: _getStatusIcon(data['adminStatus']),
          operStatusIcon: _getStatusIcon(data['operStatus']),
          displaySpeed: _formatSpeed(data['speed']),
          displayMacAddress: _formatMacAddress(data['physAddress']),
          displayType: _getInterfaceType(data['type']),
          displayLastChange: _formatTimeTicks(data['lastChange']),
          displayInOctets: _formatBytes(_parseIntValue(data['inOctets'])),
          displayOutOctets: _formatBytes(_parseIntValue(data['outOctets'])),
          displayInErrors: _parseIntValue(data['inErrors'])?.toString() ?? 'N/A',
          displayOutErrors: _parseIntValue(data['outErrors'])?.toString() ?? 'N/A',
          vlanInfo: null,
          duplex: _parseDuplex(data['duplex']),
          poeEnabled: data['poeEnabled'] == '1',
          poePowerAllocated: _parseIntValue(data['poePowerAllocated']),
          poePowerConsumption: _parseIntValue(data['poePowerConsumption']),
        ));
      });
      interfaces.sort((a, b) => a.index.compareTo(b.index));
      return Right(interfaces);
    } on SnmpAuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CancelledException {
      return Left(CancellationFailure());
    } on NoDataFetchedException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unknown error occurred while fetching interfaces: ${e.toString()}'));
    }
  }

  @override
  void cancelCurrentOperation() {
    remoteDataSource.cancelCurrentOperation();
  }

  int? _parseIntValue(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  String _getDisplayStatus(dynamic value) {
    final status = _parseIntValue(value);
    switch (status) {
      case 1:
        return 'Active (Up)';
      case 2:
        return 'Inactive (Down)';
      case 3:
        return 'Testing';
      default:
        return 'Status (${value?.toString() ?? 'N/A'})';
    }
  }

  Color _getStatusColor(dynamic value) {
    final status = _parseIntValue(value);
    switch (status) {
      case 1:
        return Colors.green.shade700;
      case 2:
        return Colors.red.shade700;
      case 3:
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade500;
    }
  }

  IconData _getStatusIcon(dynamic value) {
    final status = _parseIntValue(value);
    switch (status) {
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.cancel_outlined;
      case 3:
        return Icons.science_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return 'N/A';
    if (bytes < 1024) return '$bytes B';
    double kb = bytes / 1024.0;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    double mb = kb / 1024.0;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    double gb = mb / 1024.0;
    return '${gb.toStringAsFixed(1)} GB';
  }

  String? _formatSpeed(dynamic value) {
    if (value == null) return 'N/A';
    try {
      final bps = int.parse(value.toString());
      if (bps == 0) return 'Unknown';
      if (bps >= 1000000000) return '${(bps / 1000000000).toStringAsFixed(1)} Gbps';
      if (bps >= 1000000) return '${(bps / 1000000).toStringAsFixed(1)} Mbps';
      if (bps >= 1000) return '${(bps / 1000).toStringAsFixed(1)} Kbps';
      return '$bps bps';
    } catch (_) {
      return value.toString();
    }
  }

  String? _formatMacAddress(dynamic value) {
    if (value == null) return 'N/A';
    try {
      final hexString = value.toString().replaceAll(' ', '').replaceAll(':', '');
      if (hexString.isEmpty || hexString == '0' || hexString == '00') return 'N/A';
      final pairs = <String>[];
      for (int i = 0; i < hexString.length; i += 2) {
        if (i + 1 < hexString.length) {
          pairs.add(hexString.substring(i, i + 2).toUpperCase());
        }
      }
      return pairs.join(':');
    } catch (_) {
      return value.toString();
    }
  }

  String? _getInterfaceType(dynamic value) {
    if (value == null) return 'N/A';
    try {
      final typeCode = int.parse(value.toString());
      switch (typeCode) {
        case 6:
          return 'Ethernet';
        case 135:
          return 'L2 VLAN';
        default:
          return 'Type $typeCode';
      }
    } catch (_) {
      return value.toString();
    }
  }

  String? _formatTimeTicks(dynamic value) {
    if (value == null) return 'N/A';
    try {
      final ticks = int.parse(value.toString());
      final totalSeconds = ticks ~/ 100;
      final days = totalSeconds ~/ 86400;
      final hours = (totalSeconds % 86400) ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;
      if (days > 0) return '${days}d ${hours}h';
      return '${hours}h ${minutes}m ${seconds}s';
    } catch (_) {
      return value.toString();
    }
  }

  String? _formatUptime(String? value) {
    if (value == null) return 'N/A';
    return _formatTimeTicks(value);
  }

  String? _parseDuplex(dynamic value) {
    if (value == null) return null;
    try {
      final duplexCode = int.parse(value.toString());
      switch (duplexCode) {
        case 1:
          return 'unknown';
        case 2:
          return 'half';
        case 3:
          return 'full';
        default:
          return 'unknown';
      }
    } catch (_) {
      return null;
    }
  }
}
