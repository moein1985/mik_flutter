// lib/features/snmp/data/models/cisco_device_info_model.dart

/// Model to hold Cisco-specific device information
class CiscoDeviceInfoModel {
  // Hardware Information
  final String? modelName;
  final String? serialNumber;
  final String? iosVersion;
  final String? hardwareVersion;
  final String? description;

  // CPU Usage
  final int? cpuUsage5sec;
  final int? cpuUsage1min;
  final int? cpuUsage5min;

  // Memory Usage
  final int? memoryUsed;
  final int? memoryFree;
  final int? memoryTotal;
  final double? memoryUtilization;

  // Environmental Monitoring
  final EnvironmentalStatus? environmental;

  CiscoDeviceInfoModel({
    this.modelName,
    this.serialNumber,
    this.iosVersion,
    this.hardwareVersion,
    this.description,
    this.cpuUsage5sec,
    this.cpuUsage1min,
    this.cpuUsage5min,
    this.memoryUsed,
    this.memoryFree,
    this.memoryTotal,
    this.memoryUtilization,
    this.environmental,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'serialNumber': serialNumber,
      'iosVersion': iosVersion,
      'hardwareVersion': hardwareVersion,
      'description': description,
      'cpuUsage5sec': cpuUsage5sec,
      'cpuUsage1min': cpuUsage1min,
      'cpuUsage5min': cpuUsage5min,
      'memoryUsed': memoryUsed,
      'memoryFree': memoryFree,
      'memoryTotal': memoryTotal,
      'memoryUtilization': memoryUtilization,
      'environmental': environmental?.toJson(),
    };
  }

  factory CiscoDeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return CiscoDeviceInfoModel(
      modelName: json['modelName'] as String?,
      serialNumber: json['serialNumber'] as String?,
      iosVersion: json['iosVersion'] as String?,
      hardwareVersion: json['hardwareVersion'] as String?,
      description: json['description'] as String?,
      cpuUsage5sec: json['cpuUsage5sec'] as int?,
      cpuUsage1min: json['cpuUsage1min'] as int?,
      cpuUsage5min: json['cpuUsage5min'] as int?,
      memoryUsed: json['memoryUsed'] as int?,
      memoryFree: json['memoryFree'] as int?,
      memoryTotal: json['memoryTotal'] as int?,
      memoryUtilization: json['memoryUtilization'] as double?,
      environmental: json['environmental'] != null
          ? EnvironmentalStatus.fromJson(json['environmental'])
          : null,
    );
  }

  CiscoDeviceInfoModel copyWith({
    String? modelName,
    String? serialNumber,
    String? iosVersion,
    String? hardwareVersion,
    String? description,
    int? cpuUsage5sec,
    int? cpuUsage1min,
    int? cpuUsage5min,
    int? memoryUsed,
    int? memoryFree,
    int? memoryTotal,
    double? memoryUtilization,
    EnvironmentalStatus? environmental,
  }) {
    return CiscoDeviceInfoModel(
      modelName: modelName ?? this.modelName,
      serialNumber: serialNumber ?? this.serialNumber,
      iosVersion: iosVersion ?? this.iosVersion,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
      description: description ?? this.description,
      cpuUsage5sec: cpuUsage5sec ?? this.cpuUsage5sec,
      cpuUsage1min: cpuUsage1min ?? this.cpuUsage1min,
      cpuUsage5min: cpuUsage5min ?? this.cpuUsage5min,
      memoryUsed: memoryUsed ?? this.memoryUsed,
      memoryFree: memoryFree ?? this.memoryFree,
      memoryTotal: memoryTotal ?? this.memoryTotal,
      memoryUtilization: memoryUtilization ?? this.memoryUtilization,
      environmental: environmental ?? this.environmental,
    );
  }
}

/// Environmental status information
class EnvironmentalStatus {
  final TemperatureInfo? temperature;
  final List<FanInfo>? fans;
  final List<PowerSupplyInfo>? powerSupplies;

  EnvironmentalStatus({
    this.temperature,
    this.fans,
    this.powerSupplies,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature?.toJson(),
      'fans': fans?.map((f) => f.toJson()).toList(),
      'powerSupplies': powerSupplies?.map((p) => p.toJson()).toList(),
    };
  }

  factory EnvironmentalStatus.fromJson(Map<String, dynamic> json) {
    return EnvironmentalStatus(
      temperature: json['temperature'] != null
          ? TemperatureInfo.fromJson(json['temperature'])
          : null,
      fans: json['fans'] != null
          ? (json['fans'] as List).map((f) => FanInfo.fromJson(f)).toList()
          : null,
      powerSupplies: json['powerSupplies'] != null
          ? (json['powerSupplies'] as List)
              .map((p) => PowerSupplyInfo.fromJson(p))
              .toList()
          : null,
    );
  }
}

/// Temperature sensor information
class TemperatureInfo {
  final String? description;
  final int? value;
  final String? state; // normal, warning, critical, shutdown, notPresent, notFunctioning

  TemperatureInfo({
    this.description,
    this.value,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'value': value,
      'state': state,
    };
  }

  factory TemperatureInfo.fromJson(Map<String, dynamic> json) {
    return TemperatureInfo(
      description: json['description'] as String?,
      value: json['value'] as int?,
      state: json['state'] as String?,
    );
  }
}

/// Fan status information
class FanInfo {
  final String? description;
  final String? state; // normal, warning, critical, shutdown, notPresent, notFunctioning

  FanInfo({
    this.description,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'state': state,
    };
  }

  factory FanInfo.fromJson(Map<String, dynamic> json) {
    return FanInfo(
      description: json['description'] as String?,
      state: json['state'] as String?,
    );
  }
}

/// Power supply status information
class PowerSupplyInfo {
  final String? description;
  final String? state; // normal, warning, critical, shutdown, notPresent, notFunctioning
  final String? source; // unknown, ac, dc, externalPowerSupply, internalRedundant

  PowerSupplyInfo({
    this.description,
    this.state,
    this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'state': state,
      'source': source,
    };
  }

  factory PowerSupplyInfo.fromJson(Map<String, dynamic> json) {
    return PowerSupplyInfo(
      description: json['description'] as String?,
      state: json['state'] as String?,
      source: json['source'] as String?,
    );
  }
}

/// PoE port information
class PoePortInfo {
  final bool? enabled;
  final int? powerAllocated; // in milliwatts
  final int? powerAvailable; // in milliwatts
  final int? powerConsumption; // in milliwatts

  PoePortInfo({
    this.enabled,
    this.powerAllocated,
    this.powerAvailable,
    this.powerConsumption,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'powerAllocated': powerAllocated,
      'powerAvailable': powerAvailable,
      'powerConsumption': powerConsumption,
    };
  }

  factory PoePortInfo.fromJson(Map<String, dynamic> json) {
    return PoePortInfo(
      enabled: json['enabled'] as bool?,
      powerAllocated: json['powerAllocated'] as int?,
      powerAvailable: json['powerAvailable'] as int?,
      powerConsumption: json['powerConsumption'] as int?,
    );
  }

  // Helper to convert power to watts
  double? get powerAllocatedWatts =>
      powerAllocated != null ? powerAllocated! / 1000.0 : null;
  double? get powerAvailableWatts =>
      powerAvailable != null ? powerAvailable! / 1000.0 : null;
  double? get powerConsumptionWatts =>
      powerConsumption != null ? powerConsumption! / 1000.0 : null;
}
