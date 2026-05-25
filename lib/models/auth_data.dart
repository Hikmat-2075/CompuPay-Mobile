class AuthData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String position;
  final String? employeeName;
  final String? employeeId;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.position,
    this.employeeName,
    this.employeeId,
  });

  factory AuthData.fromJson(dynamic json) {
    final root = _asMap(json) ?? <String, dynamic>{};

    return AuthData(
      accessToken: _findString(root, const [
            'access_token',
            'accessToken',
            'token',
          ]) ??
          '',
      refreshToken: _findString(root, const [
            'refresh_token',
            'refreshToken',
          ]) ??
          '',
      role: _findString(root, const ['role']) ?? '',
      position: _findString(root, const ['position']) ?? '',
      employeeName: _findString(root, const [
        'employee_name',
        'employeeName',
        'full_name',
        'fullname',
        'fullName',
        'name',
      ]),
      employeeId: _findString(root, const [
        'employee_id',
        'employeeId',
        'employee_number',
        'employeeNumber',
        'id_karyawan',
        'idKaryawan',
        'nip',
      ]),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return null;
  }

  static String? _findString(dynamic value, List<String> keys) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }

    final normalizedKeys = keys.map(_normalize).toSet();

    for (final entry in map.entries) {
      final normalizedKey = _normalize(entry.key.toString());
      if (normalizedKeys.contains(normalizedKey)) {
        final resolved = entry.value?.toString().trim();
        if (resolved != null && resolved.isNotEmpty) {
          return resolved;
        }
      }
    }

    for (final entry in map.entries) {
      final nested = entry.value;
      if (nested is Map || nested is List) {
        final resolved = _findString(nested, keys);
        if (resolved != null && resolved.isNotEmpty) {
          return resolved;
        }
      }
    }

    return null;
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}