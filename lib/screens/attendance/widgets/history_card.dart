import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/models/attendance_models.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String? time;
  final String? status;
  final IconData icon;
  final AttendanceRecord? record;

  const HistoryCard({
    super.key,
    required this.title,
    this.time,
    this.status,
    required this.icon,
    this.record,
  });

  bool get isCheckIn => title.toLowerCase().contains('check in');
  bool get isPending => record == null;

  String get displayTime {
    if (record?.timestamp != null) {
      final dt = record!.timestamp!.toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return time ?? '--:--';
  }

  String get displayStatus {
    if (record?.status != null && record!.status!.isNotEmpty) {
      return record!.status!;
    }
    if (record != null) return 'Selesai';
    return status ?? 'Menunggu';
  }

  Color get statusColor {
    if (record != null) return const Color(0xFF16A34A);
    if (status == 'On Time') return const Color(0xFF16A34A);
    if (status == 'Late') return const Color(0xFFEF4444);
    return const Color(0xFF94A3B8);
  }

  Color get iconColor =>
      isCheckIn ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayTime,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isPending
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              displayStatus,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
