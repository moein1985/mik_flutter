import 'package:equatable/equatable.dart';

/// Model for Asterisk PBX server information
/// Uses standard HOST-RESOURCES-MIB (RFC 2790) for system information
/// Note: Asterisk-specific call/channel info requires res_snmp module
class AsteriskDeviceInfoModel extends Equatable {
  final String? osVersion;
  final int? uptimeSeconds;
  final int? numUsers;
  final int? numProcesses;
  
  // CPU Information
  final List<ProcessorInfo>? processors;
  
  // Memory Information (in bytes)
  final int? physicalMemoryTotal;
  final int? physicalMemoryUsed;
  final int? virtualMemoryTotal;
  final int? virtualMemoryUsed;
  
  // Storage Information
  final List<StorageInfo>? storages;
  
  // Asterisk Process Information
  final AsteriskProcessInfo? asteriskProcess;

  const AsteriskDeviceInfoModel({
    this.osVersion,
    this.uptimeSeconds,
    this.numUsers,
    this.numProcesses,
    this.processors,
    this.physicalMemoryTotal,
    this.physicalMemoryUsed,
    this.virtualMemoryTotal,
    this.virtualMemoryUsed,
    this.storages,
    this.asteriskProcess,
  });

  // Helper methods
  String get formattedUptime {
    if (uptimeSeconds == null) return 'Unknown';
    final duration = Duration(seconds: uptimeSeconds!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    return '${days}d ${hours}h ${minutes}m';
  }

  double? get physicalMemoryUsagePercent {
    if (physicalMemoryTotal == null || physicalMemoryUsed == null) return null;
    if (physicalMemoryTotal == 0) return 0;
    return (physicalMemoryUsed! / physicalMemoryTotal!) * 100;
  }

  double? get virtualMemoryUsagePercent {
    if (virtualMemoryTotal == null || virtualMemoryUsed == null) return null;
    if (virtualMemoryTotal == 0) return 0;
    return (virtualMemoryUsed! / virtualMemoryTotal!) * 100;
  }

  double? get averageCpuLoad {
    if (processors == null || processors!.isEmpty) return null;
    final total = processors!.fold<int>(
      0,
      (sum, proc) => sum + (proc.load ?? 0),
    );
    return total / processors!.length;
  }

  @override
  List<Object?> get props => [
        osVersion,
        uptimeSeconds,
        numUsers,
        numProcesses,
        processors,
        physicalMemoryTotal,
        physicalMemoryUsed,
        virtualMemoryTotal,
        virtualMemoryUsed,
        storages,
        asteriskProcess,
      ];
}

/// Processor information from hrProcessorTable
class ProcessorInfo extends Equatable {
  final int index;
  final String? description;
  final int? load; // 0-100

  const ProcessorInfo({
    required this.index,
    this.description,
    this.load,
  });

  @override
  List<Object?> get props => [index, description, load];
}

/// Storage information from hrStorageTable
class StorageInfo extends Equatable {
  final int index;
  final String? type; // RAM, Virtual Memory, Fixed Disk, etc.
  final String? description;
  final int? allocationUnits; // Bytes per unit
  final int? size; // In units
  final int? used; // In units

  const StorageInfo({
    required this.index,
    this.type,
    this.description,
    this.allocationUnits,
    this.size,
    this.used,
  });

  // Helper methods
  int? get totalBytes {
    if (size == null || allocationUnits == null) return null;
    return size! * allocationUnits!;
  }

  int? get usedBytes {
    if (used == null || allocationUnits == null) return null;
    return used! * allocationUnits!;
  }

  double? get usagePercent {
    if (size == null || used == null || size == 0) return null;
    return (used! / size!) * 100;
  }

  @override
  List<Object?> get props => [
        index,
        type,
        description,
        allocationUnits,
        size,
        used,
      ];
}

/// Asterisk-specific process information from hrSWRunTable
class AsteriskProcessInfo extends Equatable {
  final int index;
  final String? name;
  final String? path;
  final String? status; // running, runnable, notRunnable, invalid
  final int? cpuTime; // centi-seconds
  final int? memoryUsed; // KBytes

  const AsteriskProcessInfo({
    required this.index,
    this.name,
    this.path,
    this.status,
    this.cpuTime,
    this.memoryUsed,
  });

  double? get cpuTimeSeconds {
    if (cpuTime == null) return null;
    return cpuTime! / 100.0; // Convert centi-seconds to seconds
  }

  double? get memoryUsedMB {
    if (memoryUsed == null) return null;
    return memoryUsed! / 1024.0; // Convert KB to MB
  }

  @override
  List<Object?> get props => [
        index,
        name,
        path,
        status,
        cpuTime,
        memoryUsed,
      ];
}
