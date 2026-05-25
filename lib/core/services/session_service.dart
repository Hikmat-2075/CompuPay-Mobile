import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _accessKey = "access_token";
  static const _refreshKey = "refresh_token";
  static const _employeeNameKey = "employee_name";
  static const _employeeIdKey = "employee_id";
  static const _roleKey = "role";
  static const _positionKey = "position";

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
  // SAVE USER PROFILE
  // ======================
  static Future<void> saveUserProfile({
    String? employeeName,
    String? employeeId,
    String? role,
    String? position,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (employeeName != null && employeeName.trim().isNotEmpty) {
      await prefs.setString(_employeeNameKey, employeeName.trim());
    }

    if (employeeId != null && employeeId.trim().isNotEmpty) {
      await prefs.setString(_employeeIdKey, employeeId.trim());
    }

    if (role != null && role.trim().isNotEmpty) {
      await prefs.setString(_roleKey, role.trim());
    }

    if (position != null && position.trim().isNotEmpty) {
      await prefs.setString(_positionKey, position.trim());
    }
  }

  // ======================
  // GET REFRESH TOKEN
  // ======================
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  // ======================
  // GET USER PROFILE
  // ======================
  static Future<String?> getEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeNameKey);
  }

  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeIdKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> getPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_positionKey);
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
    await prefs.remove(_employeeNameKey);
    await prefs.remove(_employeeIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_positionKey);
  }

  // ======================
  // CLEAR SESSION
  // ======================
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}