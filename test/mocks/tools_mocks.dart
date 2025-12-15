import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/tools/domain/usecases/ping_usecase.dart';
import 'package:hsmik/features/tools/domain/usecases/traceroute_usecase.dart';
import 'package:hsmik/features/tools/domain/usecases/dns_lookup_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/get_interfaces_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/get_ip_addresses_usecase.dart';

class MockPingUseCase extends Mock implements PingUseCase {}

class MockTracerouteUseCase extends Mock implements TracerouteUseCase {}

class MockDnsLookupUseCase extends Mock implements DnsLookupUseCase {}

class MockGetInterfacesUseCase extends Mock implements GetInterfacesUseCase {}

class MockGetIpAddressesUseCase extends Mock implements GetIpAddressesUseCase {}
