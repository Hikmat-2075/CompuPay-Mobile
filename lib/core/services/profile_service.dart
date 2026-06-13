import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/models/profile_model.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileService {
  static Future<ProfileModel> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);

    print('PROFILE RESPONSE');
    print(response);

    final data = response['data'];

    return ProfileModel.fromJson(data);
  }

  static Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String email,
  }) async {
    print('USER ID = $userId');
    print('ENDPOINT = ${ApiConfig.user(userId)}');

    await ApiService.put(ApiConfig.user(userId), {
      'full_name': fullName,
      'email': email,
    });
  }

  static Future<void> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    final token = await SessionService.getToken();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.user(userId)}'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('profile_uri', imageFile.path),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print('UPLOAD STATUS = ${response.statusCode}');
    print('UPLOAD RESPONSE = $body');

    if (response.statusCode >= 400) {
      throw Exception(body);
    }
  }
}
