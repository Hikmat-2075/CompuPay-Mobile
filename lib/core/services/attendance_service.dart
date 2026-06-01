import 'dart:io';
import 'dart:typed_data';

import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/core/models/attendance_models.dart';

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

  static Future<AttendanceConfig> config() async {
    try {
      final response = await ApiService.get(ApiConfig.attendanceConfig);

      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response;

        if (data is Map<String, dynamic>) {
          return AttendanceConfig.fromJson(data);
        }

        if (data is Map) {
          final map = data.map((k, v) => MapEntry(k.toString(), v));
          return AttendanceConfig.fromJson(map);
        }
      }

      throw ApiException('Invalid attendance config response');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal mengambil konfigurasi absensi');
    }
  }

  static Future<Map<String, dynamic>> create({
    required String type,
    required DateTime datetimeLog,
    required double latitude,
    required double longitude,
    required double accuracy,
    required Uint8List photoBytes,
  }) async {
    try {
      final endpoint = type == 'check_in'
          ? ApiConfig.attendanceCheckIn
          : ApiConfig.attendanceCheckOut;

      final response = await ApiService.multipartPost(
        endpoint: endpoint,
        fields: {
          'datetime_log': datetimeLog.toIso8601String(),
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'accuracy': accuracy.toString(),
        },
        fileBytes: photoBytes,
        filename: 'attendance_photo.jpg',
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
