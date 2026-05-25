import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _accessKey = "access_token";
  static const _refreshKey = "refresh_token";

  // ======================
  // SAVE ACCESS TOKEN
  // ======================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, token);
  }

  // ======================
  // GET ACCESS TOKEN
  // ======================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  // ======================
  // SAVE REFRESH TOKEN
  // ======================
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshKey, token);
  }

  // ======================
  // GET REFRESH TOKEN
  // ======================
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  // ======================
  // CHECK LOGIN
  // ======================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey) != null;
  }

  // ======================
  // LOGOUT
  // ======================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  // ======================
  // CLEAR SESSION
  // ======================
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}