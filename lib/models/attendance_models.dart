class AttendanceConfig {
  final double officeLatitude;
  final double officeLongitude;
  final double radius;

  AttendanceConfig({
    required this.officeLatitude,
    required this.officeLongitude,
    required this.radius,
  });

  factory AttendanceConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceConfig(
      officeLatitude: _toDouble(json['officeLatitude'] ?? json['office_lat']),
      officeLongitude: _toDouble(json['officeLongitude'] ?? json['office_lng']),
      radius: _toDouble(json['radius'] ?? json['maxRadius']),
    );
  }
}

class TodayAttendance {
  final AttendanceRecord? checkIn;
  final AttendanceRecord? checkOut;
  final bool canCheckIn;
  final bool canCheckOut;
  final bool completed;

  TodayAttendance({
    this.checkIn,
    this.checkOut,
    required this.canCheckIn,
    required this.canCheckOut,
    required this.completed,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    print('TODAY RAW: $json');

    final checkInJson = json['checkIn'];
    final checkOutJson = json['checkOut'];

    return TodayAttendance(
      checkIn: checkInJson != null
          ? AttendanceRecord(
              timestamp: DateTime.tryParse(
                checkInJson['datetime_log'].toString(),
              ),
              photoUrl: checkInJson['photo_url']?.toString(),
              status: checkInJson['status']?.toString(),
            )
          : null,
      checkOut: checkOutJson != null
          ? AttendanceRecord(
              timestamp: DateTime.tryParse(
                checkOutJson['datetime_log'].toString(),
              ),
              photoUrl: checkOutJson['photo_url']?.toString(),
              status: checkOutJson['status']?.toString(),
            )
          : null,
      canCheckIn: json['canCheckIn'] ?? false,
      canCheckOut: json['canCheckOut'] ?? false,
      completed: json['completed'] ?? false,
    );
  }
}

class AttendanceRecord {
  final DateTime? timestamp;
  final String? photoUrl;
  final String? status;

  AttendanceRecord({this.timestamp, this.photoUrl, this.status});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final rawDate = json['datetime_log'];

    return AttendanceRecord(
      timestamp: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
      photoUrl: json['photo_url']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;

  // Format lengkap: 2026-05-30T08:15:00.000Z
  final fullDate = DateTime.tryParse(text);
  if (fullDate != null) return fullDate;

  // Format jam saja: 08:15 atau 08:15:00
  final timeRegex = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$');
  final match = timeRegex.firstMatch(text);

  if (match != null) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.tryParse(match.group(3) ?? '0') ?? 0,
    );
  }

  return null;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
