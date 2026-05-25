import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/models/profile_model.dart';

class ProfileService {
  static Future<ProfileModel> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);

    final data = response['data'];

    return ProfileModel.fromJson(data);
  }

  static Future<void> updateProfile({
    required String name,
    required String email,
    required String department,
    required String position,
  }) async {
    await ApiService.put(ApiConfig.profile, {
      'name': name,
      'email': email,
      'department': department,
      'position': position,
    });
  }
}
