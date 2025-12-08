import 'package:equatable/equatable.dart';

class BackupFile extends Equatable {
  final String name;
  final String size;
  final DateTime created;
  final String type;

  const BackupFile({
    required this.name,
    required this.size,
    required this.created,
    required this.type,
  });

  @override
  List<Object?> get props => [name, size, created, type];
}