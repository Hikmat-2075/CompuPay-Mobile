import 'package:flutter/material.dart';

class LiveMapSection extends StatelessWidget {
  const LiveMapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
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
      child: const Center(
        child: Text("Live Map Tracking"),
      ),
    );
  }
}