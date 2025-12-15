import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/firewall/domain/usecases/get_firewall_rules.dart';
import 'package:hsmik/features/firewall/domain/usecases/toggle_firewall_rule.dart';
import 'package:hsmik/features/firewall/domain/usecases/get_address_list_names.dart';
import 'package:hsmik/features/firewall/domain/usecases/get_address_list_by_name.dart';

class MockGetFirewallRulesUseCase extends Mock implements GetFirewallRulesUseCase {}

class MockToggleFirewallRuleUseCase extends Mock implements ToggleFirewallRuleUseCase {}

class MockGetAddressListNamesUseCase extends Mock implements GetAddressListNamesUseCase {}

class MockGetAddressListByNameUseCase extends Mock implements GetAddressListByNameUseCase {}
