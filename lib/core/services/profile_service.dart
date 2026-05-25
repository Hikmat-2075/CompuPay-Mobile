import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/services/api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);

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
  }
}
