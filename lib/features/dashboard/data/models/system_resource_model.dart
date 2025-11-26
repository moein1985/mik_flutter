import '../../domain/entities/system_resource.dart';

class SystemResourceModel extends SystemResource {
  const SystemResourceModel({
    required super.uptime,
    required super.version,
    required super.cpuLoad,
    required super.freeMemory,
    required super.totalMemory,
    required super.freeHddSpace,
    required super.totalHddSpace,
    required super.architectureName,
    required super.boardName,
    required super.platform,
  });

  factory SystemResourceModel.fromMap(Map<String, String> map) {
    return SystemResourceModel(
      uptime: map['uptime'] ?? '',
      version: map['version'] ?? '',
      cpuLoad: map['cpu-load'] ?? '0',
      freeMemory: map['free-memory'] ?? '0',
      totalMemory: map['total-memory'] ?? '0',
      freeHddSpace: map['free-hdd-space'] ?? '0',
      totalHddSpace: map['total-hdd-space'] ?? '0',
      architectureName: map['architecture-name'] ?? '',
      boardName: map['board-name'] ?? '',
      platform: map['platform'] ?? '',
    );
  }
}
