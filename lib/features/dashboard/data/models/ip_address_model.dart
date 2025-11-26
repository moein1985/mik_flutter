import '../../domain/entities/ip_address.dart';

class IpAddressModel extends IpAddress {
  const IpAddressModel({
    required super.id,
    required super.address,
    required super.network,
    required super.interfaceName,
    required super.disabled,
    required super.invalid,
    required super.dynamic,
    super.comment,
  });

  factory IpAddressModel.fromMap(Map<String, String> map) {
    return IpAddressModel(
      id: map['.id'] ?? '',
      address: map['address'] ?? '',
      network: map['network'] ?? '',
      interfaceName: map['interface'] ?? '',
      disabled: map['disabled'] == 'true',
      invalid: map['invalid'] == 'true',
      dynamic: map['dynamic'] == 'true',
      comment: map['comment'],
    );
  }
}
