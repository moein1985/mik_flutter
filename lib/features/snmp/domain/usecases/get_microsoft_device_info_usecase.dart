import '../../data/datasources/snmp_data_source.dart';
import '../../data/models/microsoft_device_info_model.dart';

/// Use case for fetching Microsoft Windows device information
class GetMicrosoftDeviceInfoUseCase {
  final SnmpDataSource dataSource;

  GetMicrosoftDeviceInfoUseCase(this.dataSource);

  Future<MicrosoftDeviceInfoModel?> call(
    String ip,
    String community,
    int port,
  ) async {
    return await dataSource.fetchMicrosoftDeviceInfo(ip, community, port);
  }
}
