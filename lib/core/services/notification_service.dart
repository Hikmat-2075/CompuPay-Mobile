import 'dart:io';

import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/core/services/fcm_service.dart';

class NotificationService {
  static Future<void> saveDeviceToken() async {
    try {
      final token = await FcmService.getToken();

      if (token == null || token.trim().isEmpty) {
        return;
      }

      await ApiService.post(ApiConfig.notificationDeviceToken, {
        'token': token,
        'platform': _getPlatform(),
      });
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal menyimpan token notifikasi');
    }
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await ApiService.get(ApiConfig.notification);

      if (response is Map && response['data'] is List) {
        return response['data'] as List<dynamic>;
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal mengambil notifikasi');
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.patch(ApiConfig.notificationRead(notificationId), {});
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal menandai notifikasi');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await ApiService.patch(ApiConfig.notificationReadAll, {});
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal menandai semua notifikasi');
    }
  }

  static String _getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';

    return 'web';
  }
}
