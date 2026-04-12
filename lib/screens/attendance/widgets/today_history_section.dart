import 'package:flutter/material.dart';
import 'history_item.dart';

class TodayHistorySection extends StatelessWidget {
  const TodayHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today History",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          HistoryItem(title: "Check In", time: "08:01 AM"),
          HistoryItem(title: "Check Out", time: "-- : --"),
        ],
      ),
    );
  }
}