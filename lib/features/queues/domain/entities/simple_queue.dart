import 'package:equatable/equatable.dart';

/// Entity representing a RouterOS simple queue
class SimpleQueue extends Equatable {
  final String id;
  final String name;
  final String target;
  final String maxLimit;
  final String burstLimit;
  final String burstThreshold;
  final String burstTime;
  final int priority;
  final String comment;
  final bool disabled;
  final String limitAt;
  final String maxLimitUpload;
  final String maxLimitDownload;
  final String burstLimitUpload;
  final String burstLimitDownload;
  final String burstThresholdUpload;
  final String burstThresholdDownload;
  final String burstTimeUpload;
  final String burstTimeDownload;

  const SimpleQueue({
    required this.id,
    required this.name,
    required this.target,
    this.maxLimit = '',
    this.burstLimit = '',
    this.burstThreshold = '',
    this.burstTime = '',
    this.priority = 8,
    this.comment = '',
    this.disabled = false,
    this.limitAt = '',
    this.maxLimitUpload = '',
    this.maxLimitDownload = '',
    this.burstLimitUpload = '',
    this.burstLimitDownload = '',
    this.burstThresholdUpload = '',
    this.burstThresholdDownload = '',
    this.burstTimeUpload = '',
    this.burstTimeDownload = '',
  });

  /// Create a copy with modified fields
  SimpleQueue copyWith({
    String? id,
    String? name,
    String? target,
    String? maxLimit,
    String? burstLimit,
    String? burstThreshold,
    String? burstTime,
    int? priority,
    String? comment,
    bool? disabled,
    String? limitAt,
    String? maxLimitUpload,
    String? maxLimitDownload,
    String? burstLimitUpload,
    String? burstLimitDownload,
    String? burstThresholdUpload,
    String? burstThresholdDownload,
    String? burstTimeUpload,
    String? burstTimeDownload,
  }) {
    return SimpleQueue(
      id: id ?? this.id,
      name: name ?? this.name,
      target: target ?? this.target,
      maxLimit: maxLimit ?? this.maxLimit,
      burstLimit: burstLimit ?? this.burstLimit,
      burstThreshold: burstThreshold ?? this.burstThreshold,
      burstTime: burstTime ?? this.burstTime,
      priority: priority ?? this.priority,
      comment: comment ?? this.comment,
      disabled: disabled ?? this.disabled,
      limitAt: limitAt ?? this.limitAt,
      maxLimitUpload: maxLimitUpload ?? this.maxLimitUpload,
      maxLimitDownload: maxLimitDownload ?? this.maxLimitDownload,
      burstLimitUpload: burstLimitUpload ?? this.burstLimitUpload,
      burstLimitDownload: burstLimitDownload ?? this.burstLimitDownload,
      burstThresholdUpload: burstThresholdUpload ?? this.burstThresholdUpload,
      burstThresholdDownload: burstThresholdDownload ?? this.burstThresholdDownload,
      burstTimeUpload: burstTimeUpload ?? this.burstTimeUpload,
      burstTimeDownload: burstTimeDownload ?? this.burstTimeDownload,
    );
  }

  /// Check if queue is enabled
  bool get isEnabled => !disabled;

  /// Get formatted upload limit
  String get formattedUploadLimit => maxLimitUpload.isNotEmpty ? maxLimitUpload : maxLimit;

  /// Get formatted download limit
  String get formattedDownloadLimit => maxLimitDownload.isNotEmpty ? maxLimitDownload : maxLimit;

  @override
  List<Object?> get props => [
        id,
        name,
        target,
        maxLimit,
        burstLimit,
        burstThreshold,
        burstTime,
        priority,
        comment,
        disabled,
        limitAt,
        maxLimitUpload,
        maxLimitDownload,
        burstLimitUpload,
        burstLimitDownload,
        burstThresholdUpload,
        burstThresholdDownload,
        burstTimeUpload,
        burstTimeDownload,
      ];
}