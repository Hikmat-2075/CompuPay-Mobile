import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  static String get apiVersion => dotenv.env['API_VERSION'] ?? '/api/v1';

  // =========================
  // AUTH
  // =========================

  static String get login => '$apiVersion/auth/login';

  static String get register => '$apiVersion/auth/register';

  static String get profile => '$apiVersion/auth/me';

  static String get refreshToken => '$apiVersion/auth/refresh';

  static String get forgetPassword => '$apiVersion/auth/forget-password';
  static String get verifyOtp => '$apiVersion/auth/verify-otp';
  static String get resetPassword => '$apiVersion/auth/reset-password';

  // =========================
  // LEAVE REQUEST
  // =========================

  static String get leaveRequest {
    final endpoint = dotenv.env['LEAVE_REQUEST_ENDPOINT'];

    if (endpoint != null && endpoint.trim().isNotEmpty) {
      return endpoint.trim();
    }

    return '$apiVersion/leaveRequest';
  }

  // =========================
  // PAYROLL / PAYSLIP
  // =========================

  static String get payroll {
    final payrollEndpoint = dotenv.env['PAYROLL_ENDPOINT'];

    if (payrollEndpoint != null && payrollEndpoint.trim().isNotEmpty) {
      return payrollEndpoint.trim();
    }

    return '$apiVersion/payroll';
  }

  // =========================
  // ATTENDANCE
  // =========================

  static String get attendance => '$apiVersion/attendance';

  static String get attendanceConfig => '$apiVersion/attendance/config';

  static String get attendanceToday => '$apiVersion/attendance/today';

  static String get attendanceCheckIn => '$apiVersion/attendance/check-in';

  static String get attendanceCheckOut => '$apiVersion/attendance/check-out';
}
