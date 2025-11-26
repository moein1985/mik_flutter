import '../../domain/entities/firewall_rule.dart';

class FirewallRuleModel extends FirewallRule {
  const FirewallRuleModel({
    required super.id,
    required super.chain,
    required super.action,
    required super.disabled,
    required super.invalid,
    required super.dynamic,
    super.srcAddress,
    super.dstAddress,
    super.protocol,
    super.dstPort,
    super.comment,
    super.bytes,
    super.packets,
  });

  factory FirewallRuleModel.fromMap(Map<String, String> map) {
    return FirewallRuleModel(
      id: map['.id'] ?? '',
      chain: map['chain'] ?? '',
      action: map['action'] ?? '',
      disabled: map['disabled'] == 'true',
      invalid: map['invalid'] == 'true',
      dynamic: map['dynamic'] == 'true',
      srcAddress: map['src-address'],
      dstAddress: map['dst-address'],
      protocol: map['protocol'],
      dstPort: map['dst-port'],
      comment: map['comment'],
      bytes: int.tryParse(map['bytes'] ?? ''),
      packets: int.tryParse(map['packets'] ?? ''),
    );
  }
}
