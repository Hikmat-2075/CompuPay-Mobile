import 'package:flutter/material.dart';

class BottomAction extends StatelessWidget {
  final VoidCallback? onContactHR;

  const BottomAction({super.key, this.onContactHR});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.43,
            color: Color(0xFF494454),
          ),
        ),
        GestureDetector(
          onTap: onContactHR,
          child: const Text(
            "Contact HR",
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.43,
              color: Color(0xFF6B38D4),
            ),
          ),
        ),
      ],
    );
  }
}