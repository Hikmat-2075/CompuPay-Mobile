import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({
    super.key,
    required this.controller,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 276,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "PASSWORD",
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

          Container(
            height: 59,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E2EB),
              ),
            ),
            child: TextField(
              controller: widget.controller, // 🔥 FIX INI

              obscureText: isHidden,
              decoration: InputDecoration(
                hintText: "Enter your password",
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

                // ICON KIRI
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: SvgPicture.asset(
                    "assets/icons/lock.svg",
                    width: 20,
                  ),
                ),

                prefixIconConstraints: const BoxConstraints(
                  minWidth: 20,
                ),

                // ICON MATA KANAN
                suffixIcon: IconButton(
                  icon: Icon(
                    isHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF7B7486),
                  ),
                  onPressed: () {
                    setState(() {
                      isHidden = !isHidden;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}