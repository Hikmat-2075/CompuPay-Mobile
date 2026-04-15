import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 276,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6B38D4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336B38D4),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Color(0x336B38D4),
                  offset: Offset(0, 10),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/icons/dompet.svg",
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 12),

          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: "Manrope",
                fontWeight: FontWeight.w800,
                fontSize: 30,
                height: 1.2,
                letterSpacing: -1.5,
              ),
              children: [
                TextSpan(
                  text: "Com",
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: "p",
                  style: TextStyle(color: Color(0xFF6B38D4)),
                ),
                TextSpan(
                  text: "u",
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: "P",
                  style: TextStyle(color: Color(0xFF6B38D4)),
                ),
                TextSpan(
                  text: "ay",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const SizedBox(
            width: 261,
            child: Text(
              "The Financial Concierge for Employees",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.43,
                color: Color(0xFF494454),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
