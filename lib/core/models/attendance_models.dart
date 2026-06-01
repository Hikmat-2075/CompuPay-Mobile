class AttendanceConfig {
  final double officeLatitude;
  final double officeLongitude;
  final double radius; // in meters

  AttendanceConfig({
    required this.officeLatitude,
    required this.officeLongitude,
    required this.radius,
  });

  factory AttendanceConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceConfig(
      officeLatitude: (json['officeLatitude'] as num).toDouble(),
      officeLongitude: (json['officeLongitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
    );
  }
}

class AttendanceRecord {
  final DateTime? timestamp;
  final String? photoUrl;
  final String? status;

  AttendanceRecord({this.timestamp, this.photoUrl, this.status});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      timestamp: json['time'] != null
          ? DateTime.tryParse(json['time'].toString())
          : null,
      photoUrl: json['photo']?.toString(),
      status: json['status']?.toString(),
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
    return TodayAttendance(
      checkIn: json['checkIn'] != null
          ? AttendanceRecord.fromJson(json['checkIn'] as Map<String, dynamic>)
          : null,
      checkOut: json['checkOut'] != null
          ? AttendanceRecord.fromJson(json['checkOut'] as Map<String, dynamic>)
          : null,
      canCheckIn: json['canCheckIn'] == true,
      canCheckOut: json['canCheckOut'] == true,
      completed: json['completed'] == true,
    );
  }
}
