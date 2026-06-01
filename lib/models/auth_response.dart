import 'package:compupay_mobile/models/auth_data.dart';

class AuthResponse {
  final int code;
  final String status;
  final String message;
  final AuthData data;

  AuthResponse({
    required this.code,
    required this.status,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      code: json["code"] ?? 0,
      status: json["status"]?.toString() ?? '',
      message: json["message"]?.toString() ?? '',
      data: AuthData.fromJson(json["data"] ?? json),
    );
  }
}
