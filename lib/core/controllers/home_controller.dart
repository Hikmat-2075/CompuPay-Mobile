import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/services/attendance_service.dart';
import 'package:compupay_mobile/core/services/profile_service.dart';
import 'package:compupay_mobile/core/models/attendance_models.dart';
import 'package:compupay_mobile/models/profile_model.dart';

class HomeController extends ChangeNotifier {
  bool loading = false;
  String? error;

  ProfileModel? profile;
  TodayAttendance? todayAttendance;

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ProfileService.getProfile(),
        AttendanceService.today(),
      ]);

      profile = results[0] as ProfileModel;

      final attendanceMap = results[1] as Map<String, dynamic>;

      if (attendanceMap.isNotEmpty) {
        todayAttendance = _parseTodayAttendance(attendanceMap);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await init();
  }

  TodayAttendance _parseTodayAttendance(Map<String, dynamic> json) {
    final checkInJson = json['checkIn'];
    final checkOutJson = json['checkOut'];

    return TodayAttendance(
      checkIn: checkInJson is Map
          ? AttendanceRecord(
              timestamp: DateTime.tryParse(
                checkInJson['datetime_log']?.toString() ??
                    checkInJson['time']?.toString() ??
                    '',
              )?.toLocal(),
              photoUrl:
                  checkInJson['photo_url']?.toString() ??
                  checkInJson['photo']?.toString(),
              status: checkInJson['status']?.toString(),
            )
          : null,
      checkOut: checkOutJson is Map
          ? AttendanceRecord(
              timestamp: DateTime.tryParse(
                checkOutJson['datetime_log']?.toString() ??
                    checkOutJson['time']?.toString() ??
                    '',
              )?.toLocal(),
              photoUrl:
                  checkOutJson['photo_url']?.toString() ??
                  checkOutJson['photo']?.toString(),
              status: checkOutJson['status']?.toString(),
            )
          : null,
      canCheckIn: json['canCheckIn'] == true,
      canCheckOut: json['canCheckOut'] == true,
      completed: json['completed'] == true,
    );
  }
}