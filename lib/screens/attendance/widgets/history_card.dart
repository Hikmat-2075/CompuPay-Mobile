import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final IconData icon;

  const HistoryCard({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
  });

  bool get isCheckIn => title == "Check In";
  bool get isPending => time == "--:--";

  Color get statusColor {
    if (status == "On Time") return Colors.green;
    if (status == "Late") return Colors.red;
    return const Color(0xFF94A3B8);
  }

  Color get timeColor {
    if (isPending) return const Color(0xFFCBD5E1);
    return Colors.black;
  }

  Color get iconColor {
    if (isCheckIn) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// TIME
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: timeColor,
            ),
          ),

          const Spacer(),

          /// STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}