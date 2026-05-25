import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/controllers/auth_controller.dart';

import 'package:compupay_mobile/screens/login/widgets/email_field.dart';
import 'package:compupay_mobile/screens/login/widgets/password_field.dart';
import 'package:compupay_mobile/screens/login/widgets/login_button.dart';
import 'package:compupay_mobile/navigation/main_navigation.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = AuthController(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password wajib diisi")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // ============================
    // API LOGIN (DI-COMMENT)
    // ============================

    /*
  await authController.login(
    emailController.text,
    passwordController.text,
  );
  */

    // ============================
    // MOCK LOGIN (langsung pindah page)
    // ============================

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.5),
      child: SizedBox(
        width: 276,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmailField(controller: emailController),

            const SizedBox(height: 24),

            PasswordField(controller: passwordController),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 16),

            LoginButton(
              onPressed: isLoading ? null : handleLogin,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
