import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:compupay_mobile/screens/attendance/widgets/attendance_top_bar.dart';
import 'package:compupay_mobile/screens/attendance/widgets/live_map_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/location_status_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/today_history_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/camera_photo_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/attendance_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  File? image;
  final ImagePicker picker = ImagePicker();

  Future<void> takePhoto() async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera, // 🔥 ini langsung buka kamera HP
      imageQuality: 80,
    );

    if (photo == null) return;

    setState(() {
      image = File(photo.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AttendanceTopBar(
        onBack: () => Navigator.pop(context),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            const LiveMapSection(),

            const SizedBox(height: 16),

            /// FOTO HASIL
            CameraPhotoSection(image: image),

            const SizedBox(height: 16),

            const LocationStatusSection(),

            const SizedBox(height: 16),

            /// BUTTON
            TakeAttendancePhotoButton(
              onPressed: takePhoto,
            ),

            const SizedBox(height: 16),

            const TodayHistorySection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}