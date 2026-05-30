import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:compupay_mobile/core/models/attendance_models.dart';
import 'package:compupay_mobile/core/services/attendance_service.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';

class AttendanceController extends ChangeNotifier {
  static const double maxAllowedAccuracy = 100;

  bool loading = false;
  String? error;

  AttendanceConfig? config;
  TodayAttendance? today;

  Position? position;
  double? distanceToOffice;
  bool insideRadius = false;

  File? photo;
  Uint8List? photoBytes;
  bool uploading = false;

  final ImagePicker _picker = ImagePicker();

  bool get isGpsAccurate {
    if (position == null) return false;
    return position!.accuracy <= maxAllowedAccuracy;
  }

  bool get canTakeAttendancePhoto {
    return insideRadius && !uploading;
  }

  bool get canSubmitAttendance {
    return insideRadius && photoBytes != null && !uploading;
  }

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await fetchConfig();
      await _determinePosition();
      await fetchToday();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConfig() async {
    config = await AttendanceService.config();
    notifyListeners();
  }

  Future<void> fetchToday() async {
    final res = await AttendanceService.today();

    if (res.isNotEmpty) {
      print('TODAY RAW: $res');

      final checkInJson = res['checkIn'];
      final checkOutJson = res['checkOut'];

      today = TodayAttendance(
        checkIn: checkInJson != null
            ? AttendanceRecord(
                timestamp: DateTime.tryParse(
                  checkInJson['datetime_log'].toString(),
                )?.toLocal(),
                photoUrl: checkInJson['photo_url']?.toString(),
                status: checkInJson['status']?.toString(),
              )
            : null,
        checkOut: checkOutJson != null
            ? AttendanceRecord(
                timestamp: DateTime.tryParse(
                  checkOutJson['datetime_log'].toString(),
                )?.toLocal(),
                photoUrl: checkOutJson['photo_url']?.toString(),
                status: checkOutJson['status']?.toString(),
              )
            : null,
        canCheckIn: res['canCheckIn'] ?? false,
        canCheckOut: res['canCheckOut'] ?? false,
        completed: res['completed'] ?? false,
      );

      print('CHECK IN: ${today?.checkIn}');
      print('CHECK IN TIMESTAMP: ${today?.checkIn?.timestamp}');
    } else {
      today = null;
    }

    notifyListeners();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    if (config != null && position != null) {
      distanceToOffice = Geolocator.distanceBetween(
        position!.latitude,
        position!.longitude,
        config!.officeLatitude,
        config!.officeLongitude,
      );

      insideRadius = distanceToOffice! <= config!.radius;
    }

    notifyListeners();
  }

  Future<void> refreshLocationAndToday() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _determinePosition();
      await fetchToday();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pickPhoto() async {
    if (!canTakeAttendancePhoto) {
      throw Exception('Lokasi belum valid untuk mengambil foto');
    }

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked == null) return;

    photo = File(picked.path);
    photoBytes = await picked.readAsBytes();

    notifyListeners();
  }

  Future<void> _createAttendance(String type) async {
    if (config == null || position == null) {
      throw Exception('Location or config not loaded');
    }

    if (!insideRadius) {
      throw Exception('Anda berada di luar radius kantor');
    }

    if (photoBytes == null) {
      throw Exception('Foto wajib diambil sebelum absen');
    }

    uploading = true;
    error = null;
    notifyListeners();

    try {
      await AttendanceService.create(
        type: type,
        datetimeLog: DateTime.now(),
        latitude: position!.latitude,
        longitude: position!.longitude,
        accuracy: position!.accuracy,
        photoBytes: photoBytes!,
      );

      photo = null;
      photoBytes = null;

      await fetchToday();
    } on ApiException catch (e) {
      error = e.message;
      rethrow;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      uploading = false;
      notifyListeners();
    }
  }

  Future<void> checkIn() async => _createAttendance('check_in');

  Future<void> checkOut() async => _createAttendance('check_out');
}
