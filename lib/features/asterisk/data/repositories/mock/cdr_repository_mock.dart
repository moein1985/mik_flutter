import '../../../domain/entities/cdr_record.dart';
import '../../../domain/repositories/icdr_repository.dart';
import '../../../core/result.dart';

/// Mock repository for CDR (Call Detail Records)
class CdrRepositoryMock implements ICdrRepository {
  @override
  Future<Result<List<CdrRecord>>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();

      // Generate mock CDR records
      List<CdrRecord> mockRecords = [
        CdrRecord(
          callDate: now.subtract(const Duration(hours: 1)).toIso8601String(),
          clid: '"John Doe" <1001>',
          src: '1001',
          dst: '1002',
          dcontext: 'from-internal',
          channel: 'SIP/1001-00000001',
          dstChannel: 'SIP/1002-00000002',
          lastApp: 'Dial',
          lastData: 'SIP/1002,30,tTr',
          duration: '125',
          billsec: '120',
          disposition: 'ANSWERED',
          amaflags: 'DOCUMENTATION',
          uniqueid: '1703000001.1',
          userfield: '',
        ),
        CdrRecord(
          callDate: now.subtract(const Duration(hours: 2)).toIso8601String(),
          clid: '"Jane Smith" <1002>',
          src: '1002',
          dst: '1003',
          dcontext: 'from-internal',
          channel: 'SIP/1002-00000003',
          dstChannel: 'SIP/1003-00000004',
          lastApp: 'Dial',
          lastData: 'SIP/1003,30,tTr',
          duration: '45',
          billsec: '40',
          disposition: 'ANSWERED',
          amaflags: 'DOCUMENTATION',
          uniqueid: '1703000002.2',
          userfield: '',
        ),
        CdrRecord(
          callDate: now.subtract(const Duration(hours: 3)).toIso8601String(),
          clid: '"Support" <1003>',
          src: '1003',
          dst: '09123456789',
          dcontext: 'from-internal',
          channel: 'SIP/1003-00000005',
          dstChannel: 'DAHDI/g0/09123456789',
          lastApp: 'Dial',
          lastData: 'DAHDI/g0/09123456789,60,tTr',
          duration: '0',
          billsec: '0',
          disposition: 'NO ANSWER',
          amaflags: 'DOCUMENTATION',
          uniqueid: '1703000003.3',
          userfield: '',
        ),
        CdrRecord(
          callDate: now.subtract(const Duration(hours: 4)).toIso8601String(),
          clid: '"External" <09121234567>',
          src: '09121234567',
          dst: '1001',
          dcontext: 'from-external',
          channel: 'DAHDI/i1/09121234567',
          dstChannel: 'SIP/1001-00000006',
          lastApp: 'Dial',
          lastData: 'SIP/1001,30,tTr',
          duration: '300',
          billsec: '295',
          disposition: 'ANSWERED',
          amaflags: 'DOCUMENTATION',
          uniqueid: '1703000004.4',
          userfield: '',
        ),
        CdrRecord(
          callDate: now.subtract(const Duration(hours: 5)).toIso8601String(),
          clid: '"Sales" <1004>',
          src: '1004',
          dst: '1001',
          dcontext: 'from-internal',
          channel: 'SIP/1004-00000007',
          dstChannel: 'SIP/1001-00000008',
          lastApp: 'Dial',
          lastData: 'SIP/1001,30,tTr',
          duration: '15',
          billsec: '0',
          disposition: 'BUSY',
          amaflags: 'DOCUMENTATION',
          uniqueid: '1703000005.5',
          userfield: '',
        ),
      ];

      // Apply date range filters
      var filteredRecords = mockRecords;

      if (startDate != null || endDate != null) {
        filteredRecords = filteredRecords.where((record) {
          final callDate = DateTime.parse(record.callDate);
          
          if (startDate != null && callDate.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && callDate.isAfter(endDate)) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply src filter
      if (src != null && src.isNotEmpty) {
        filteredRecords = filteredRecords.where((record) {
          return record.src.contains(src);
        }).toList();
      }

      // Apply dst filter
      if (dst != null && dst.isNotEmpty) {
        filteredRecords = filteredRecords.where((record) {
          return record.dst.contains(dst);
        }).toList();
      }

      // Apply disposition filter
      if (disposition != null && disposition != 'ALL' && disposition.isNotEmpty) {
        filteredRecords = filteredRecords.where((record) {
          return record.disposition == disposition;
        }).toList();
      }

      // Apply limit
      if (filteredRecords.length > limit) {
        filteredRecords = filteredRecords.sublist(0, limit);
      }

      return Success(filteredRecords);
    } catch (e) {
      return Failure('Failed to fetch CDR records: $e');
    }
  }
}
