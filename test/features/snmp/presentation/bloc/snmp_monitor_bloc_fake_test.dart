import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/snmp/data/datasources/fake_snmp_data_source.dart';
import 'package:hsmik/features/snmp/data/repositories/snmp_repository_impl.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_device_info_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_interface_status_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_cisco_device_info_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_microsoft_device_info_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_asterisk_device_info_usecase.dart';
import 'package:hsmik/features/snmp/presentation/bloc/snmp_monitor_bloc.dart';
import 'package:hsmik/features/snmp/presentation/bloc/snmp_monitor_event.dart';
import 'package:hsmik/features/snmp/presentation/bloc/snmp_monitor_state.dart';
import 'package:hsmik/features/snmp/data/datasources/snmp_data_source.dart';
import 'package:hsmik/features/snmp/data/models/cisco_device_info_model.dart';
import 'package:hsmik/features/snmp/data/models/microsoft_device_info_model.dart';
import 'package:hsmik/features/snmp/data/models/asterisk_device_info_model.dart' as asterisk;

class ThrowingDataSource extends SnmpDataSource {
  final Exception toThrow;
  ThrowingDataSource(this.toThrow);

  @override
  Future<Map<String, dynamic>> fetchDeviceInfo(String ip, String community, int port) async {
    throw toThrow;
  }

  @override
  Future<Map<int, Map<String, dynamic>>> fetchInterfacesData(String ip, String community, int port) async {
    throw toThrow;
  }

  @override
  Future<CiscoDeviceInfoModel?> fetchCiscoDeviceInfo(String ip, String community, int port) async {
    throw toThrow;
  }

  @override
  Future<MicrosoftDeviceInfoModel?> fetchMicrosoftDeviceInfo(String ip, String community, int port) async {
    throw toThrow;
  }

  @override
  Future<asterisk.AsteriskDeviceInfoModel?> fetchAsteriskDeviceInfo(String ip, String community, int port) async {
    throw toThrow;
  }
}

void main() {
  group('SnmpMonitorBloc integration with Fake', () {
    blocTest<SnmpMonitorBloc, SnmpMonitorState>(
      'emits [Loading, Success] on successful fetch',
      build: () {
        final fake = FakeSnmpDataSource(seed: 5, minDelayMs: 1, maxDelayMs: 3);
        final repo = SnmpRepositoryImpl(fake);
        return SnmpMonitorBloc(
          getDeviceInfoUseCase: GetDeviceInfoUseCase(repo),
          getInterfaceStatusUseCase: GetInterfaceStatusUseCase(repo),
          getCiscoDeviceInfoUseCase: GetCiscoDeviceInfoUseCase(fake),
          getMicrosoftDeviceInfoUseCase: GetMicrosoftDeviceInfoUseCase(fake),
          getAsteriskDeviceInfoUseCase: GetAsteriskDeviceInfoUseCase(fake),
        );
      },
      act: (bloc) => bloc.add(const FetchDataRequested(ip: '10.0.0.1', community: 'public', port: 161)),
      wait: const Duration(seconds: 2),
      expect: () => [
        const SnmpMonitorLoading(),
        isA<SnmpMonitorSuccess>(),
      ],
      verify: (bloc) {
        final state = bloc.state;
        if (state is SnmpMonitorSuccess) {
          expect(state.deviceInfo.sysName?.toLowerCase(), contains('cisco'));
          expect(state.interfaces.length, 24);
          expect(state.ciscoInfo, isNotNull);
        }
      },
    );

    blocTest<SnmpMonitorBloc, SnmpMonitorState>(
      'emits Failure when repository returns network error',
      build: () {
        final ds = ThrowingDataSource(NetworkException('simulated'));
        final repo = SnmpRepositoryImpl(ds);
        return SnmpMonitorBloc(
          getDeviceInfoUseCase: GetDeviceInfoUseCase(repo),
          getInterfaceStatusUseCase: GetInterfaceStatusUseCase(repo),
          getCiscoDeviceInfoUseCase: GetCiscoDeviceInfoUseCase(ds),
          getMicrosoftDeviceInfoUseCase: GetMicrosoftDeviceInfoUseCase(ds),
          getAsteriskDeviceInfoUseCase: GetAsteriskDeviceInfoUseCase(ds),
        );
      },
      act: (bloc) => bloc.add(const FetchDataRequested(ip: '10.0.0.100', community: 'public', port: 161)),
      wait: const Duration(seconds: 1),
      expect: () => [
        const SnmpMonitorLoading(),
        isA<SnmpMonitorFailure>(),
      ],
    );

    blocTest<SnmpMonitorBloc, SnmpMonitorState>(
      'cancellation returns to initial state',
      build: () {
        final fake = FakeSnmpDataSource(seed: 7, minDelayMs: 1, maxDelayMs: 3);
        final repo = SnmpRepositoryImpl(fake);
        return SnmpMonitorBloc(
          getDeviceInfoUseCase: GetDeviceInfoUseCase(repo),
          getInterfaceStatusUseCase: GetInterfaceStatusUseCase(repo),
          getCiscoDeviceInfoUseCase: GetCiscoDeviceInfoUseCase(fake),
          getMicrosoftDeviceInfoUseCase: GetMicrosoftDeviceInfoUseCase(fake),
          getAsteriskDeviceInfoUseCase: GetAsteriskDeviceInfoUseCase(fake),
        );
      },
      act: (bloc) {
        bloc.add(const FetchDataRequested(ip: '10.0.0.7', community: 'public', port: 161));
        bloc.add(const FetchCancelled());
      },
      wait: const Duration(seconds: 1),
      expect: () => [
        const SnmpMonitorLoading(),
        const SnmpMonitorInitial(),
        isA<SnmpMonitorFailure>(),
      ],
    );
  });
}
