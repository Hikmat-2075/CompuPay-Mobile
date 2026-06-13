class ProfileModel {
  final String name;
  final String employeeId;
  final String email;
  final String department;
  final String position;
  final String role;
  final String? photo;
  final String id;

  ProfileModel({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.email,
    required this.department,
    required this.position,
    required this.role,
    this.photo,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: _readString(json, ['full_name', 'fullName', 'name']),

      employeeId: _readString(json, [
        'employee_id',
        'employeeId',
        'employee_number',
        'employeeNumber',
        'nik',
      ]),
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: _parseDepartment(json['department']),
      position: _parsePosition(json),
      role: _parseRole(json['role']),
      photo: json['profile_uri']?.toString() ?? json['photo']?.toString(),    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employeeId': employeeId,
      'email': email,
      'department': department,
      'position': position,
      'role': role,
      'photo': photo,
    };
  }
static String _parseDepartment(dynamic department) {
    if (department is Map<String, dynamic>) {
      return department['name']?.toString() ?? '';
    }

    return department?.toString() ?? '';
  }

  static String _parseRole(dynamic role) {
    if (role is Map<String, dynamic>) {
      return role['name']?.toString() ?? '';
    }

    return role?.toString() ?? '';
  }

  static String _parsePosition(Map<String, dynamic> json) {
    final position = json['position'];

    if (position is Map<String, dynamic>) {
      return position['name']?.toString() ?? '';
    }

    if (position != null) {
      return position.toString();
    }

    final role = json['role'];

    if (role is Map<String, dynamic>) {
      return role['name']?.toString() ?? '';
    }

    return '';
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }
}
