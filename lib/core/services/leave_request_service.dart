import 'dart:io';

import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/models/leave_request_models.dart';

class LeaveRequestService {
  static Future<List<LeaveRequestItem>> list({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.leaveRequest}?pagination[page]=$page&pagination[limit]=$limit',
      );

      return parseLeaveRequestList(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal mengambil daftar pengajuan');
    }
  }

  static Future<LeaveRequestItem> create({
    required LeaveRequestCreatePayload payload,
    File? attachment,
  }) async {
    try {
      final response = await ApiService.multipartPost(
        endpoint: ApiConfig.leaveRequest,
        fields: payload.toFields(),
        file: attachment,
        fileField: 'attachment',
      );

      return parseLeaveRequestDetail(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal membuat pengajuan');
    }
  }
}
