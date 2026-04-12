import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 276,
      height: 60,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF6B38D4),
            Color(0xFF8455EF),
          ],
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x446B38D4),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x446B38D4),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),

      child: TextButton(

        onPressed: onPressed,

        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          backgroundColor: Colors.transparent,
        ),

        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Login",
                style: TextStyle(
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 28 / 18,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}