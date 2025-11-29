import 'package:equatable/equatable.dart';

class HotspotUser extends Equatable {
  final String id;
  final String name;
  final String? password;
  final String? profile;
  final String? server;
  final String? comment;
  final bool disabled;
  
  // Limits - محدودیت‌ها
  final String? limitUptime;      // محدودیت زمان (مثل 1h, 30m, 1d)
  final String? limitBytesIn;     // محدودیت دانلود
  final String? limitBytesOut;    // محدودیت آپلود  
  final String? limitBytesTotal;  // محدودیت کل ترافیک
  
  // Statistics - آمار مصرف (فقط خواندنی)
  final String? uptime;           // زمان استفاده شده
  final String? bytesIn;          // دانلود شده
  final String? bytesOut;         // آپلود شده
  final String? packetsIn;
  final String? packetsOut;

  const HotspotUser({
    required this.id,
    required this.name,
    this.password,
    this.profile,
    this.server,
    this.comment,
    required this.disabled,
    // Limits
    this.limitUptime,
    this.limitBytesIn,
    this.limitBytesOut,
    this.limitBytesTotal,
    // Statistics
    this.uptime,
    this.bytesIn,
    this.bytesOut,
    this.packetsIn,
    this.packetsOut,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        password,
        profile,
        server,
        comment,
        disabled,
        limitUptime,
        limitBytesIn,
        limitBytesOut,
        limitBytesTotal,
        uptime,
        bytesIn,
        bytesOut,
        packetsIn,
        packetsOut,
      ];
  
  /// Returns true if user has any limit set
  bool get hasLimits => 
      limitUptime != null || 
      limitBytesIn != null || 
      limitBytesOut != null || 
      limitBytesTotal != null;
  
  /// Returns true if user has any usage statistics
  bool get hasStatistics =>
      (uptime != null && uptime != '0s') ||
      (bytesIn != null && bytesIn != '0') ||
      (bytesOut != null && bytesOut != '0');
}
