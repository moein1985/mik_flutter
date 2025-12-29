class DeviceInfo {
  final String? sysName;
  final String? sysDescr;
  final String? sysLocation;
  final String? sysContact;
  final String? sysUpTime;
  final String? sysObjectID;
  
  DeviceInfo({
    this.sysName,
    this.sysDescr,
    this.sysLocation,
    this.sysContact,
    this.sysUpTime,
    this.sysObjectID,
  });
  
  bool get hasData => sysName != null || sysDescr != null || sysLocation != null || 
                     sysContact != null || sysUpTime != null;
}
