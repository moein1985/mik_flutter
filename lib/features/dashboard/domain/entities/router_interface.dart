import 'package:equatable/equatable.dart';

class RouterInterface extends Equatable {
  final String id;
  final String name;
  final String type;
  final bool running;
  final bool disabled;
  final String? comment;
  final String? macAddress;

  const RouterInterface({
    required this.id,
    required this.name,
    required this.type,
    required this.running,
    required this.disabled,
    this.comment,
    this.macAddress,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        running,
        disabled,
        comment,
        macAddress,
      ];
}
