import 'package:flutter/material.dart';

import 'package:compupay_mobile/core/controllers/attendance_controller.dart';
import 'package:compupay_mobile/screens/attendance/widgets/attendance_button.dart';
import 'package:compupay_mobile/screens/attendance/widgets/attendance_top_bar.dart';
import 'package:compupay_mobile/screens/attendance/widgets/camera_photo_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/live_map_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/location_status_section.dart';
import 'package:compupay_mobile/screens/attendance/widgets/today_history_section.dart';
import 'package:compupay_mobile/shared/widgets/app_alert.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController controller = AttendanceController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onChange);
    controller.init();
  }

  @override
  void dispose() {
    controller.removeListener(_onChange);
    controller.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  Future<void> _onActionPressed(bool isCheckIn) async {
    try {
      if (!controller.insideRadius) {
        throw Exception('Anda berada di luar radius kantor');
      }

      if (controller.photoBytes == null) {
        throw Exception('Ambil foto terlebih dahulu sebelum absen');
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isCheckIn ? 'Konfirmasi Check In' : 'Konfirmasi Check Out',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: controller.photoBytes != null
                      ? Image.memory(controller.photoBytes!, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pastikan wajah terlihat jelas sebelum mengirim absensi.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kirim'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      if (isCheckIn) {
        await controller.checkIn();
      } else {
        await controller.checkOut();
      }

      if (!mounted) return;
      AppAlert.success(
        context,
        message: isCheckIn
            ? 'Check in berhasil dikirim.'
            : 'Check out berhasil dikirim.',
      );
    } catch (e) {
      if (!mounted) return;
      AppAlert.error(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.loading;
    final error = controller.error;
    final cfg = controller.config;
    final today = controller.today;
    final canCheckIn = today?.canCheckIn == true;
    final canCheckOut = today?.canCheckOut == true;
    final canUseAttendance = controller.canSubmitAttendance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => controller.refreshLocationAndToday(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderCard(isLoading: isLoading),
                const SizedBox(height: 14),
                LiveMapSection(
                  officeLatitude: cfg?.officeLatitude,
                  officeLongitude: cfg?.officeLongitude,
                  radius: cfg?.radius,
                  userPosition: controller.position,
                ),
                const SizedBox(height: 14),
                if (error != null) ...[
                  _ErrorCard(message: error),
                  const SizedBox(height: 14),
                ],
                LocationStatusSection(
                  insideRadius: controller.insideRadius,
                  distanceToOffice: controller.distanceToOffice,
                  radius: cfg?.radius,
                ),
                const SizedBox(height: 14),
                CameraPhotoSection(
                  image: controller.photo,
                  imageBytes: controller.photoBytes,
                  enabled: controller.canTakeAttendancePhoto,
                  loading: controller.uploading,
                  onPickPhoto: controller.pickPhoto,
                ),
                const SizedBox(height: 14),
                TodayHistorySection(attendance: today),
                const SizedBox(height: 18),
                if (today == null && !isLoading)
                  const _EmptyAttendanceCard()
                else if (today != null && today.completed)
                  const _CompletedCard()
                else if (today != null) ...[
                  TakeAttendancePhotoButton(
                    label: 'Check In',
                    icon: Icons.login_rounded,
                    enabled: canCheckIn && canUseAttendance,
                    loading: controller.uploading && canCheckIn,
                    onPressed: () {
                      _onActionPressed(true);
                    },
                  ),
                  const SizedBox(height: 12),
                  TakeAttendancePhotoButton(
                    label: 'Check Out',
                    icon: Icons.logout_rounded,
                    enabled: canCheckOut && canUseAttendance,
                    loading: controller.uploading && canCheckOut,
                    onPressed: () => _onActionPressed(false),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isLoading;

  const _HeaderCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x338B5CF6),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Presensi Karyawan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading
                      ? 'Memuat lokasi dan data absensi...'
                      : 'Pastikan Anda berada di radius kantor.',
                  style: const TextStyle(
                    color: Color(0xFFEDE9FE),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFBE123C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAttendanceCard extends StatelessWidget {
  const _EmptyAttendanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Belum ada jadwal absensi hari ini.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  const _CompletedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
          SizedBox(width: 8),
          Text(
            'Absensi hari ini selesai',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
