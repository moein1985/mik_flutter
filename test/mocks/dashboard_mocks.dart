import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:hsmik/features/dashboard/domain/usecases/get_system_resources_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/get_interfaces_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/toggle_interface_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/get_ip_addresses_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/ip_address_usecases.dart';
import 'package:hsmik/features/dashboard/domain/usecases/get_firewall_rules_usecase.dart';
import 'package:hsmik/features/dashboard/domain/usecases/toggle_firewall_rule_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockGetSystemResourcesUseCase extends Mock implements GetSystemResourcesUseCase {}

class MockGetInterfacesUseCase extends Mock implements GetInterfacesUseCase {}

class MockToggleInterfaceUseCase extends Mock implements ToggleInterfaceUseCase {}

class MockGetIpAddressesUseCase extends Mock implements GetIpAddressesUseCase {}

class MockAddIpAddressUseCase extends Mock implements AddIpAddressUseCase {}

class MockUpdateIpAddressUseCase extends Mock implements UpdateIpAddressUseCase {}

class MockRemoveIpAddressUseCase extends Mock implements RemoveIpAddressUseCase {}

class MockToggleIpAddressUseCase extends Mock implements ToggleIpAddressUseCase {}

class MockGetFirewallRulesUseCase extends Mock implements GetFirewallRulesUseCase {}

class MockToggleFirewallRuleUseCase extends Mock implements ToggleFirewallRuleUseCase {}
