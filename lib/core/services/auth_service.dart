import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/core/services/profile_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/models/auth_response.dart';

class AuthService {
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await ApiService.post(ApiConfig.login, {
        'email': email,
        'password': password,
      });

      final authResponse = AuthResponse.fromJson(response);

      await SessionService.saveToken(authResponse.data.accessToken);
      await SessionService.saveRefreshToken(authResponse.data.refreshToken);

      await SessionService.saveUserProfile(
        employeeName: authResponse.data.employeeName,
        employeeId: authResponse.data.employeeId,
        role: authResponse.data.role,
        position: authResponse.data.position,
      );

      await fetchAndSaveProfile();

      return authResponse;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal memproses data login');
    }
  }

  static Future<void> fetchAndSaveProfile() async {
    try {
      final profile = await ProfileService.getProfile();

      final fullName = _getString(profile, const [
        'full_name',
        'fullName',
        'name',
      ]);

      final employeeNumber = _getString(profile, const [
        'employee_number',
        'employeeNumber',
        'id',
      ]);

      final role = _getString(profile, const ['role']);

      final position = _getNestedString(profile, const [
        'position.name',
        'position_name',
        'positionName',
        'position',
      ]);

      await SessionService.saveUserProfile(
        employeeName: fullName,
        employeeId: employeeNumber,
        role: role,
        position: position,
      );
    } catch (_) {
      // Jangan gagalkan login hanya karena profile gagal dimuat.
      // Token tetap sudah tersimpan.
    }
  }

  static String? _getString(Map<String, dynamic> map, List<String> keys) {
    final normalizedKeys = keys.map(_normalizeKey).toSet();

    for (final entry in map.entries) {
      final key = _normalizeKey(entry.key);

      if (normalizedKeys.contains(key)) {
        final value = entry.value?.toString().trim();

        if (value != null && value.isNotEmpty && value != 'null') {
          return value;
        }
      }
    }

    return null;
  }

  static String? _getNestedString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (key.contains('.')) {
        final parts = key.split('.');
        dynamic current = map;

        for (final part in parts) {
          if (current is Map) {
            current = current[part];
          } else {
            current = null;
            break;
          }
        }

        final value = current?.toString().trim();

        if (value != null && value.isNotEmpty && value != 'null') {
          return value;
        }
      } else {
        final value = _getString(map, [key]);

        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  static String _normalizeKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
