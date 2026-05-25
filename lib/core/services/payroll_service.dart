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
    } catch (_) {
      throw ApiException('Gagal mengambil data payroll');
    }
  }

  static Future<PayslipItem?> getPayslipDetail(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.payroll}/$id');

      final data = _extractData(response);
      final map = asMap(data);

      if (map == null) {
        return null;
      }

      return PayslipItem.fromJson(map);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal mengambil detail payroll');
    }
  }

  static dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['data'] ?? response['result'] ?? response;
    }

    if (response is Map) {
      final normalized = response.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      return normalized['data'] ?? normalized['result'] ?? normalized;
    }

    return response;
  }
}
