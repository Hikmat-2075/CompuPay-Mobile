import 'dart:io';

import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';

class AttendanceService {
  static Future<Map<String, dynamic>> today() async {
    try {
      final response = await ApiService.get(ApiConfig.attendanceToday);

      if (response is Map<String, dynamic>) {
        final data = response['data'];

        if (data is Map<String, dynamic>) {
          return data;
        }

        if (data is Map) {
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }

      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal mengambil absensi hari ini');
    }
  }

  static Future<Map<String, dynamic>> create({
    required String type,
    required DateTime datetimeLog,
    required double latitude,
    required double longitude,
    required double accuracy,
    File? photo,
  }) async {
    try {
      final response = await ApiService.multipartPost(
        endpoint: ApiConfig.attendance,
        fields: {
          'type': type,
          'datetime_log': datetimeLog.toIso8601String(),
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'accuracy': accuracy.toString(),
        },
        file: photo,
        fileField: 'photo',
      );

      if (response is Map<String, dynamic>) {
        final data = response['data'];

        if (data is Map<String, dynamic>) {
          return data;
        }

        if (data is Map) {
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }

      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal mengirim absensi');
    }
  }
}
