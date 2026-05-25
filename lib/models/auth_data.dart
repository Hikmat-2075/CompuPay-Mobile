class AuthData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String position;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.position,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
      role: json["role"],
      position: json["position"],
    );
  }
}