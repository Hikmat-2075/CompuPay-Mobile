import 'package:compupay_mobile/screens/login/widgets/auth_card.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 448,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              SizedBox(height: 32),

              // Auth Card / Login Form
              AuthCard(),
            ],
          ),
        ),
      ),
    );
  }
}