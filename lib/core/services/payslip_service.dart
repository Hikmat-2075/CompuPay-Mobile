import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/models/payslip_models.dart';

class PayslipService {
  static const _candidateEndpoints = [
    'payslip',
    'payslips',
    'user/payslip',
    'user/payslips',
    'employee/payslip',
    'employee/payslips',
    'salary/payslip',
    'salary/payslips',
  ];

  static Future<List<PayslipItem>> getPayslips() async {
    ApiException? lastException;

    for (final endpoint in _buildEndpoints()) {
      try {
        final response = await ApiService.get(endpoint);
        final items = parsePayslipItems(response);

        if (items.isNotEmpty) {
          return items;
        }
      } on ApiException catch (e) {
        lastException = e;
        if (e.statusCode != 404) {
          rethrow;
        }
      }
    }

    if (lastException != null && lastException.statusCode != 404) {
      throw lastException;
    }

    return const [];
  }

  static List<String> _buildEndpoints() {
    final endpoints = <String>{};

    void addCandidate(String endpoint) {
      final normalized = endpoint.trim();
      if (normalized.isNotEmpty) {
        endpoints.add(normalized.startsWith('/') ? normalized : '/$normalized');
      }
    }

    addCandidate(ApiConfig.payslip);

    for (final path in _candidateEndpoints) {
      addCandidate('${ApiConfig.apiVersion}/$path');
    }

    return endpoints.toList(growable: false);
  }
}
