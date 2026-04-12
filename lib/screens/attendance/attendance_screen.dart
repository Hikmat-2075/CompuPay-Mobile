import 'package:flutter/material.dart';
import 'package:compupay_mobile/screens/attendance/widgets/attendance_top_bar.dart';
import 'package:compupay_mobile/screens/attendance/widgets/live_map_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/camera_photo_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/today_history_section.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AttendanceTopBar(
        onBack: () {
          Navigator.pop(context);
        },
      ),

      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            LiveMapSection(),
            SizedBox(height: 16),
            CameraPhotoSection(),
            SizedBox(height: 16),
            TodayHistorySection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
