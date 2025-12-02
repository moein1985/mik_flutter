import 'package:equatable/equatable.dart';

/// Represents a Walled Garden entry
/// Walled Garden allows access to specific destinations without authentication
class WalledGarden extends Equatable {
  final String id;
  final String? server;          // Hotspot server name
  final String? srcAddress;      // Source address/subnet
  final String? dstAddress;      // Destination address/subnet
  final String? dstHost;         // Destination host (domain name)
  final String? dstPort;         // Destination port
  final String? path;            // URL path
  final String action;           // allow, deny
  final String? method;          // HTTP method
  final String? comment;
  final bool disabled;

  const WalledGarden({
    required this.id,
    this.server,
    this.srcAddress,
    this.dstAddress,
    this.dstHost,
    this.dstPort,
    this.path,
    required this.action,
    this.method,
    this.comment,
    required this.disabled,
  });

  @override
  List<Object?> get props => [
        id,
        server,
        srcAddress,
        dstAddress,
        dstHost,
        dstPort,
        path,
        action,
        method,
        comment,
        disabled,
      ];
  
  /// Returns true if this entry allows access
  bool get isAllowed => action == 'allow';
  
  /// Returns a description of what this entry matches
  String get matchDescription {
    final parts = <String>[];
    if (dstHost != null && dstHost!.isNotEmpty) parts.add(dstHost!);
    if (dstAddress != null && dstAddress!.isNotEmpty) parts.add(dstAddress!);
    if (dstPort != null && dstPort!.isNotEmpty) parts.add(':$dstPort');
    if (path != null && path!.isNotEmpty) parts.add(path!);
    return parts.isEmpty ? '*' : parts.join('');
  }
}
