import 'package:flutter/material.dart';

class LocationStatusSection extends StatelessWidget {
  const LocationStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 326,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              size: 16,
              color: Color(0xFF7C3AED),
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [

                /// TITLE
                Text(
                  "CURRENT LOCATION",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(height: 4),

                /// ADDRESS
                Text(
                  "Jl. Gatot Subroto No. 123, Jakarta Selatan",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 4),

                /// ACCURACY
                Text(
                  "Accuracy: High (within 5 meters)",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}