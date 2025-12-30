import '../../data/datasources/snmp_data_source.dart';
import '../../data/models/asterisk_device_info_model.dart';

/// Use case for fetching Asterisk PBX device information
class GetAsteriskDeviceInfoUseCase {
  final SnmpDataSource dataSource;

  GetAsteriskDeviceInfoUseCase(this.dataSource);

  Future<AsteriskDeviceInfoModel?> call(
    String ip,
    String community,
    int port,
  ) async {
    return await dataSource.fetchAsteriskDeviceInfo(ip, community, port);
  }
}
