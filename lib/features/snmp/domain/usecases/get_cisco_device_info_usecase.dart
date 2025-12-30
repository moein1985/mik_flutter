import '../../data/datasources/snmp_data_source.dart';
import '../../data/models/cisco_device_info_model.dart';

class GetCiscoDeviceInfoUseCase {
  final SnmpDataSource dataSource;

  GetCiscoDeviceInfoUseCase(this.dataSource);

  Future<CiscoDeviceInfoModel?> call(
    String ip,
    String community,
    int port,
  ) async {
    return await dataSource.fetchCiscoDeviceInfo(ip, community, port);
  }
}
