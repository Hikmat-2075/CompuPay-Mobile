import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/models/auth_response.dart';

class AuthService {
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await ApiService.post(ApiConfig.login, {
        "email": email,
        "password": password,
      });

      final authResponse = AuthResponse.fromJson(response);

      // simpan token
      await SessionService.saveToken(authResponse.data.accessToken);
      await SessionService.saveRefreshToken(authResponse.data.refreshToken);

      return authResponse;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Gagal memproses data login");
    }
  }
}
