import 'package:compupay_mobile/screens/login/widgets/bottom_action.dart';
import 'package:compupay_mobile/screens/login/widgets/logo_section.dart';
import 'package:flutter/material.dart';
import 'login_form.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      height: 631.5,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // penting!
        children: const [
          Column(
            children: [
              LogoSection(),
              SizedBox(height: 39.5),
              LoginForm(),
            ],
          ),
          BottomAction(),
        ],
      ),
    );
  }
}