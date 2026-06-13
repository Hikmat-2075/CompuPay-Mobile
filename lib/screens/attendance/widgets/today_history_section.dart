import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/models/attendance_models.dart';
import 'package:compupay_mobile/screens/attendance/widgets/history_card.dart';

class TodayHistorySection extends StatelessWidget {
  final TodayAttendance? attendance;

  const TodayHistorySection({super.key, this.attendance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF7C3AED),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Absensi Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ringkasan check in dan check out',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HistoryCard(
                  title: 'Check In',
                  icon: Icons.login_rounded,
                  record: attendance?.checkIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HistoryCard(
                  title: 'Check Out',
                  icon: Icons.logout_rounded,
                  record: attendance?.checkOut,
                ),
              ),
            ],
          ),
          if (attendance?.completed == true) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Absensi hari ini sudah selesai ✓',
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
