import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? '/api/v1';

  // AUTH
  static String get login => '$apiVersion/auth/login';
  static String get register => '$apiVersion/auth/register';
  static String get profile => '$apiVersion/auth/me';
  static String get refreshToken => '$apiVersion/auth/refresh';

  // LEAVE REQUEST
  static String get leaveRequest {
    final endpoint = dotenv.env['LEAVE_REQUEST_ENDPOINT'];

    if (endpoint != null && endpoint.trim().isNotEmpty) {
      return endpoint.trim();
    }

    return '$apiVersion/leaveRequest';
  }

  // PAYROLL
  static String get payroll {
    final payrollEndpoint = dotenv.env['PAYROLL_ENDPOINT'];
    final payslipEndpoint = dotenv.env['PAYSLIP_ENDPOINT'];

    if (payrollEndpoint != null && payrollEndpoint.trim().isNotEmpty) {
      return payrollEndpoint.trim();
    }

    if (payslipEndpoint != null && payslipEndpoint.trim().isNotEmpty) {
      return payslipEndpoint.trim();
    }

    return "$apiVersion/payroll";
  }

  // ATTENDANCE
  static String get attendance => '$apiVersion/attendance';
  static String get attendanceToday => '$apiVersion/attendance/today';
}
