import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/models/payslip_models.dart';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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
      throw ApiException('Gagal mengambil data payroll');
    }
  }

  static Future<PayslipItem?> getPayslipDetail(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.payroll}/$id');

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
      throw ApiException('Gagal mengambil detail payroll');
    }
  }

  static Future<File> downloadPayslipPdf({
    required String payrollId,
    required String fileName,
  }) async {
    try {
      final bytes = await ApiService.downloadFile(
        '${ApiConfig.payroll}/$payrollId/download-pdf',
      );

      final directory = await getApplicationDocumentsDirectory();

      final safeFileName = fileName
          .replaceAll(' ', '-')
          .replaceAll('/', '-')
          .replaceAll('\\', '-');

      final file = File('${directory.path}/$safeFileName.pdf');

      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        throw ApiException(
          'PDF berhasil disimpan, tetapi gagal dibuka otomatis',
        );
      }

      return file;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal download payslip PDF');
    }
  }
}
