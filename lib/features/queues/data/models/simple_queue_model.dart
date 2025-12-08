import '../../domain/entities/simple_queue.dart';

/// Model for simple queue data from RouterOS API
class SimpleQueueModel extends SimpleQueue {
  const SimpleQueueModel({
    required super.id,
    required super.name,
    required super.target,
    super.maxLimit,
    super.burstLimit,
    super.burstThreshold,
    super.burstTime,
    super.priority,
    super.comment,
    super.disabled,
    super.limitAt,
    super.maxLimitUpload,
    super.maxLimitDownload,
    super.burstLimitUpload,
    super.burstLimitDownload,
    super.burstThresholdUpload,
    super.burstThresholdDownload,
    super.burstTimeUpload,
    super.burstTimeDownload,
  });

  /// Create model from RouterOS queue response
  factory SimpleQueueModel.fromRouterOS(Map<String, String> data) {
    return SimpleQueueModel(
      id: data['.id'] ?? '',
      name: data['name'] ?? '',
      target: data['target'] ?? '',
      maxLimit: data['max-limit'] ?? '',
      burstLimit: data['burst-limit'] ?? '',
      burstThreshold: data['burst-threshold'] ?? '',
      burstTime: data['burst-time'] ?? '',
      priority: int.tryParse(data['priority'] ?? '8') ?? 8,
      comment: data['comment'] ?? '',
      disabled: data['disabled'] == 'true',
      limitAt: data['limit-at'] ?? '',
      maxLimitUpload: data['max-limit-upload'] ?? '',
      maxLimitDownload: data['max-limit-download'] ?? '',
      burstLimitUpload: data['burst-limit-upload'] ?? '',
      burstLimitDownload: data['burst-limit-download'] ?? '',
      burstThresholdUpload: data['burst-threshold-upload'] ?? '',
      burstThresholdDownload: data['burst-threshold-download'] ?? '',
      burstTimeUpload: data['burst-time-upload'] ?? '',
      burstTimeDownload: data['burst-time-download'] ?? '',
    );
  }

  /// Create model from multiple RouterOS responses
  static List<SimpleQueueModel> fromRouterOSList(List<Map<String, String>> dataList) {
    return dataList.map((data) => SimpleQueueModel.fromRouterOS(data)).toList();
  }

  /// Convert to entity
  SimpleQueue toEntity() {
    return SimpleQueue(
      id: id,
      name: name,
      target: target,
      maxLimit: maxLimit,
      burstLimit: burstLimit,
      burstThreshold: burstThreshold,
      burstTime: burstTime,
      priority: priority,
      comment: comment,
      disabled: disabled,
      limitAt: limitAt,
      maxLimitUpload: maxLimitUpload,
      maxLimitDownload: maxLimitDownload,
      burstLimitUpload: burstLimitUpload,
      burstLimitDownload: burstLimitDownload,
      burstThresholdUpload: burstThresholdUpload,
      burstThresholdDownload: burstThresholdDownload,
      burstTimeUpload: burstTimeUpload,
      burstTimeDownload: burstTimeDownload,
    );
  }

  /// Convert entity to model
  factory SimpleQueueModel.fromEntity(SimpleQueue entity) {
    return SimpleQueueModel(
      id: entity.id,
      name: entity.name,
      target: entity.target,
      maxLimit: entity.maxLimit,
      burstLimit: entity.burstLimit,
      burstThreshold: entity.burstThreshold,
      burstTime: entity.burstTime,
      priority: entity.priority,
      comment: entity.comment,
      disabled: entity.disabled,
      limitAt: entity.limitAt,
      maxLimitUpload: entity.maxLimitUpload,
      maxLimitDownload: entity.maxLimitDownload,
      burstLimitUpload: entity.burstLimitUpload,
      burstLimitDownload: entity.burstLimitDownload,
      burstThresholdUpload: entity.burstThresholdUpload,
      burstThresholdDownload: entity.burstThresholdDownload,
      burstTimeUpload: entity.burstTimeUpload,
      burstTimeDownload: entity.burstTimeDownload,
    );
  }

  /// Convert to RouterOS command parameters
  Map<String, String> toRouterOSParams() {
    final params = <String, String>{};

    if (name.isNotEmpty) params['name'] = name;
    if (target.isNotEmpty) params['target'] = target;
    if (maxLimit.isNotEmpty) params['max-limit'] = maxLimit;
    if (burstLimit.isNotEmpty) params['burst-limit'] = burstLimit;
    if (burstThreshold.isNotEmpty) params['burst-threshold'] = burstThreshold;
    if (burstTime.isNotEmpty) params['burst-time'] = burstTime;
    params['priority'] = priority.toString();
    if (comment.isNotEmpty) params['comment'] = comment;
    params['disabled'] = disabled.toString();

    // Advanced limits
    if (limitAt.isNotEmpty) params['limit-at'] = limitAt;
    if (maxLimitUpload.isNotEmpty) params['max-limit-upload'] = maxLimitUpload;
    if (maxLimitDownload.isNotEmpty) params['max-limit-download'] = maxLimitDownload;
    if (burstLimitUpload.isNotEmpty) params['burst-limit-upload'] = burstLimitUpload;
    if (burstLimitDownload.isNotEmpty) params['burst-limit-download'] = burstLimitDownload;
    if (burstThresholdUpload.isNotEmpty) params['burst-threshold-upload'] = burstThresholdUpload;
    if (burstThresholdDownload.isNotEmpty) params['burst-threshold-download'] = burstThresholdDownload;
    if (burstTimeUpload.isNotEmpty) params['burst-time-upload'] = burstTimeUpload;
    if (burstTimeDownload.isNotEmpty) params['burst-time-download'] = burstTimeDownload;

    return params;
  }
}