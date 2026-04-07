import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 276,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // LABEL
          const Text(
            "EMAIL ADDRESS",
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.33,
              letterSpacing: 1.2,
              color: Color(0xFF494454),
            ),
          ),

          const SizedBox(height: 6),

          // INPUT
          Container(
            height: 59,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E2EB),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "name@company.com",
                hintStyle: const TextStyle(
                  fontFamily: "Inter",
                  fontSize: 16,
                  color: Color(0xFF7B7486),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(
                  48,
                  18,
                  16,
                  18,
                ),

                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Image.asset(
                    "assets/icons/email.png",
                    width: 20,
                    height: 15,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}