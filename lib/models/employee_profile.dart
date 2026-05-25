class EmployeeProfile {
  final String fullName;
  final String position;
  final String employeeId;
  final String email;
  final String department;
  final String avatar;

  EmployeeProfile({
    required this.fullName,
    required this.position,
    required this.employeeId,
    required this.email,
    required this.department,
    required this.avatar,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      fullName: json['full_name'] ?? '',
      position: json['position'] ?? '',
      employeeId: json['employee_id'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}