import 'package:compupay_mobile/screens/login/widgets/email_field.dart';
import 'package:compupay_mobile/screens/login/widgets/login_button.dart';
import 'package:compupay_mobile/screens/login/widgets/password_field.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.5),
      child: SizedBox(
        width: 276,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // supaya full width
          children: [
            const EmailField(),
            const SizedBox(height: 24),
            const PasswordField(),
            const SizedBox(height: 8), // jarak sebelum Forgot Password
            Align(
              alignment: Alignment.centerRight, // teks di kanan
              child: TextButton(
                onPressed: () {
                  // TODO: navigasi ke halaman reset password
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // hilangkan padding default
                  minimumSize: const Size(0, 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.43,
                    color: Color(0xFF6B38D4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            LoginButton(
              onPressed: () {
                // TODO : aksi Login
              },
            ),
          ],
        ),
      ),
    );
  }
}