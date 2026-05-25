import 'package:flutter/material.dart';
import 'package:compupay_mobile/screens/attendance/widgets/history_card.dart';

class TodayHistorySection extends StatelessWidget {
  const TodayHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Today's History",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191C1D),
                ),
              ),
              Text(
                "View All",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// CARDS
          Row(
            children: const [
              Expanded(
                child: HistoryCard(
                  title: "Check In",
                  time: "08:30 AM",
                  status: "On Time",
                  icon: Icons.login,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: HistoryCard(
                  title: "Check Out",
                  time: "--:--",
                  status: "Pending",
                  icon: Icons.logout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}