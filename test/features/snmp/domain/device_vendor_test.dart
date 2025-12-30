import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/snmp/domain/entities/saved_snmp_device.dart';

void main() {
  test('DeviceVendor.fromString parses correctly', () {
    expect(DeviceVendor.fromString('cisco'), DeviceVendor.cisco);
    expect(DeviceVendor.fromString('ASTERISK'), DeviceVendor.asterisk);
    expect(DeviceVendor.fromString('unknown'), DeviceVendor.general);
  });

  test('displayName returns human readable names', () {
    expect(DeviceVendor.cisco.displayName, 'Cisco');
    expect(DeviceVendor.general.displayName, 'General');
  });
}
