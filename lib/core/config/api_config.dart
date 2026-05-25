import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? '';
  static String get payslip {
    final endpoint = dotenv.env['PAYSLIP_ENDPOINT'];
    if (endpoint != null && endpoint.trim().isNotEmpty) {
      return endpoint.trim();
    }

    return "$apiVersion/payslip";
  }
  static String get leaveRequest {
    final endpoint = dotenv.env['LEAVE_REQUEST_ENDPOINT'];
    if (endpoint != null && endpoint.trim().isNotEmpty) {
      return endpoint.trim();
    }

    return "$apiVersion/leave-request";
  }

  // 🔐 AUTH
  static String get login => "$apiVersion/auth/login";
  static String get register => "$apiVersion/auth/register";

  // 🕒 ATTENDANCE
  static String get attendance => "$apiVersion/attendance";
  static String get checkIn => "$apiVersion/attendance/check-in";
  static String get checkOut => "$apiVersion/attendance/check-out";

  // 👤 USER
  static String get profile => "$apiVersion/user/profile";
}