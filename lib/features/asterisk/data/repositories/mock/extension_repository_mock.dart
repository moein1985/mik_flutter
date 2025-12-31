import 'dart:math';
import '../../../domain/entities/extension.dart';
import '../../../domain/repositories/iextension_repository.dart';
import '../../../core/result.dart';
import 'mock_data.dart';

/// Mock implementation of Extension Repository for testing
/// 
/// This is a simplified version that returns mock data without
/// requiring full domain/data layer implementation.
/// Use this for development and testing before implementing the real repository.
class ExtensionRepositoryMock implements IExtensionRepository {
  @override
  Future<Result<List<Extension>>> getExtensions() async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(200)));

      // Simulate dynamic changes: randomly change status of one extension
      final random = Random();
      final modifiedPeers = List<Map<String, String>>.from(MockData.mockSipPeers);

      if (random.nextBool()) {
        final index = random.nextInt(modifiedPeers.length);
        final peer = modifiedPeers[index];
        final currentStatus = peer['Status']!;
        if (currentStatus.contains('OK')) {
          modifiedPeers[index] = {
            ...peer,
            'Status': 'UNREACHABLE',
          };
        } else if (currentStatus == 'UNREACHABLE') {
          modifiedPeers[index] = {
            ...peer,
            'Status': 'OK (${20 + random.nextInt(80)} ms)',
          };
        }
      }

      // Convert to Extension entities
      final extensions = modifiedPeers.map((peer) {
        final status = peer['Status'] ?? '';
        final isOnline = status.contains('OK');
        int? latency;
        if (isOnline) {
          final match = RegExp(r'\((\d+)\s*ms\)').firstMatch(status);
          if (match != null) {
            latency = int.tryParse(match.group(1) ?? '');
          }
        }
        final name = peer['ObjectName'] ?? '';
        final isTrunk = int.tryParse(name) == null;

        return Extension(
          name: name,
          location: peer['IPaddress'] ?? '',
          status: status,
          isOnline: isOnline,
          latency: latency,
          isTrunk: isTrunk,
        );
      }).toList();

      return Success(extensions);
    } catch (e) {
      return Failure('Failed to fetch extensions: $e');
    }
  }
}