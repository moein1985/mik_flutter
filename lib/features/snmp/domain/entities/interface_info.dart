import 'package:flutter/material.dart';

class VlanInfo {
  final int vlanId;
  final String portMode;

  VlanInfo({required this.vlanId, required this.portMode});

  Map<String, dynamic> toJson() {
    return {
      'vlanId': vlanId,
      'portMode': portMode,
    };
  }

  factory VlanInfo.fromJson(Map<String, dynamic> json) {
    return VlanInfo(
      vlanId: json['vlanId'] as int,
      portMode: json['portMode'] as String,
    );
  }
}

class InterfaceInfo {
  final int index;
  final String name;
  final String rawAdminStatus;
  final String rawOperStatus;
  final String? rawSpeed;
  final String? rawMacAddress;
  final String? rawType;
  final String? rawLastChange;
  final int? rawInOctets;
  final int? rawOutOctets;
  final int? rawInErrors;
  final int? rawOutErrors;
  final String displayAdminStatus;
  final String displayOperStatus;
  final Color adminStatusColor;
  final Color operStatusColor;
  final IconData adminStatusIcon;
  final IconData operStatusIcon;
  final String? displaySpeed;
  final String? displayMacAddress;
  final String? displayType;
  final String? displayLastChange;
  final String displayInOctets;
  final String displayOutOctets;
  final String displayInErrors;
  final String displayOutErrors;
  final VlanInfo? vlanInfo;
  final String? duplex; // half, full, auto
  final bool? poeEnabled;
  final int? poePowerAllocated; // in milliwatts
  final int? poePowerConsumption; // in milliwatts

  InterfaceInfo({
    required this.index,
    required this.name,
    required this.rawAdminStatus,
    required this.rawOperStatus,
    this.rawSpeed,
    this.rawMacAddress,
    this.rawType,
    this.rawLastChange,
    this.rawInOctets,
    this.rawOutOctets,
    this.rawInErrors,
    this.rawOutErrors,
    required this.displayAdminStatus,
    required this.displayOperStatus,
    required this.adminStatusColor,
    required this.operStatusColor,
    required this.adminStatusIcon,
    required this.operStatusIcon,
    this.displaySpeed,
    this.displayMacAddress,
    this.displayType,
    this.displayLastChange,
    required this.displayInOctets,
    required this.displayOutOctets,
    required this.displayInErrors,
    required this.displayOutErrors,
    this.vlanInfo,
    this.duplex,
    this.poeEnabled,
    this.poePowerAllocated,
    this.poePowerConsumption,
  });

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'rawAdminStatus': rawAdminStatus,
      'rawOperStatus': rawOperStatus,
      'rawSpeed': rawSpeed,
      'rawMacAddress': rawMacAddress,
      'rawType': rawType,
      'rawLastChange': rawLastChange,
      'rawInOctets': rawInOctets,
      'rawOutOctets': rawOutOctets,
      'rawInErrors': rawInErrors,
      'rawOutErrors': rawOutErrors,
      'displayAdminStatus': displayAdminStatus,
      'displayOperStatus': displayOperStatus,
      'adminStatusColor': adminStatusColor.toARGB32(),
      'operStatusColor': operStatusColor.toARGB32(),
      'adminStatusIcon': adminStatusIcon.codePoint,
      'operStatusIcon': operStatusIcon.codePoint,
      'displaySpeed': displaySpeed,
      'displayMacAddress': displayMacAddress,
      'displayType': displayType,
      'displayLastChange': displayLastChange,
      'displayInOctets': displayInOctets,
      'displayOutOctets': displayOutOctets,
      'displayInErrors': displayInErrors,
      'displayOutErrors': displayOutErrors,
      'vlanInfo': vlanInfo?.toJson(),
      'duplex': duplex,
      'poeEnabled': poeEnabled,
      'poePowerAllocated': poePowerAllocated,
      'poePowerConsumption': poePowerConsumption,
    };
  }

  factory InterfaceInfo.fromJson(Map<String, dynamic> json) {
    return InterfaceInfo(
      index: json['index'] as int,
      name: json['name'] as String,
      rawAdminStatus: json['rawAdminStatus'] as String,
      rawOperStatus: json['rawOperStatus'] as String,
      rawSpeed: json['rawSpeed'] as String?,
      rawMacAddress: json['rawMacAddress'] as String?,
      rawType: json['rawType'] as String?,
      rawLastChange: json['rawLastChange'] as String?,
      rawInOctets: json['rawInOctets'] as int?,
      rawOutOctets: json['rawOutOctets'] as int?,
      rawInErrors: json['rawInErrors'] as int?,
      rawOutErrors: json['rawOutErrors'] as int?,
      displayAdminStatus: json['displayAdminStatus'] as String,
      displayOperStatus: json['displayOperStatus'] as String,
      adminStatusColor: Color(json['adminStatusColor'] as int),
      operStatusColor: Color(json['operStatusColor'] as int),
      adminStatusIcon: IconData(json['adminStatusIcon'] as int, fontFamily: 'MaterialIcons'),
      operStatusIcon: IconData(json['operStatusIcon'] as int, fontFamily: 'MaterialIcons'),
      displaySpeed: json['displaySpeed'] as String?,
      displayMacAddress: json['displayMacAddress'] as String?,
      displayType: json['displayType'] as String?,
      displayLastChange: json['displayLastChange'] as String?,
      displayInOctets: json['displayInOctets'] as String,
      displayOutOctets: json['displayOutOctets'] as String,
      displayInErrors: json['displayInErrors'] as String,
      displayOutErrors: json['displayOutErrors'] as String,
      vlanInfo: json['vlanInfo'] != null ? VlanInfo.fromJson(json['vlanInfo'] as Map<String, dynamic>) : null,
      duplex: json['duplex'] as String?,
      poeEnabled: json['poeEnabled'] as bool?,
      poePowerAllocated: json['poePowerAllocated'] as int?,
      poePowerConsumption: json['poePowerConsumption'] as int?,
    );
  }

  // Helper to get PoE power in watts
  double? get poePowerAllocatedWatts =>
      poePowerAllocated != null ? poePowerAllocated! / 1000.0 : null;
  double? get poePowerConsumptionWatts =>
      poePowerConsumption != null ? poePowerConsumption! / 1000.0 : null;
}
