import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/models/payslip_models.dart';

class PayrollService {
  static Future<List<PayslipItem>> getPayslips({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.payroll}?pagination[page]=$page&pagination[limit]=$limit',
      );

      return parsePayslipItems(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal mengambil data payroll',
      );
    }
  }

  static Future<PayslipItem?> getPayslipDetail(
    String id,
  ) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.payroll}/$id',
      );

      if (response is Map<String, dynamic>) {
        final data = response['data'];

        if (data is Map<String, dynamic>) {
          return PayslipItem.fromJson(data);
        }
      }

      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal mengambil detail payroll',
      );
    }
  }
}