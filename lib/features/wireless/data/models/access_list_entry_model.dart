import '../../domain/entities/access_list_entry.dart';

class AccessListEntryModel extends AccessListEntry {
  const AccessListEntryModel({
    required super.id,
    required super.macAddress,
    required super.interface,
    required super.authentication,
    required super.forwarding,
    super.apTxLimit,
    super.clientTxLimit,
    super.signalRange,
    super.time,
    super.comment,
  });

  factory AccessListEntryModel.fromMap(Map<String, String> map) {
    return AccessListEntryModel(
      id: map['.id'] ?? '',
      macAddress: map['mac-address'] ?? '',
      interface: map['interface'] ?? '',
      authentication: map['authentication'] == 'yes',
      forwarding: map['forwarding'] == 'yes',
      apTxLimit: map['ap-tx-limit'],
      clientTxLimit: map['client-tx-limit'],
      signalRange: map['signal-range'],
      time: map['time'],
      comment: map['comment'],
    );
  }

  Map<String, String> toMap() {
    final map = <String, String>{
      'mac-address': macAddress,
      'interface': interface,
      'authentication': authentication ? 'yes' : 'no',
      'forwarding': forwarding ? 'yes' : 'no',
    };

    if (apTxLimit != null) map['ap-tx-limit'] = apTxLimit!;
    if (clientTxLimit != null) map['client-tx-limit'] = clientTxLimit!;
    if (signalRange != null) map['signal-range'] = signalRange!;
    if (time != null) map['time'] = time!;
    if (comment != null) map['comment'] = comment!;

    return map;
  }
}
