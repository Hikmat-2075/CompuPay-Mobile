import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/controllers/auth_controller.dart';
import 'package:compupay_mobile/screens/login/login_screen.dart';
import 'package:compupay_mobile/shared/widgets/app_alert.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late AuthController authController;

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    authController = AuthController(context);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleResetPassword() async {
    final password = passwordController.text;
    final confirmation = confirmPasswordController.text;

    if (password.isEmpty || confirmation.isEmpty) {
      AppAlert.warning(
        context,
        message: 'Password wajib diisi.',
      );
      return;
    }

    if (password != confirmation) {
      AppAlert.warning(
        context,
        message: 'Konfirmasi password tidak sama.',
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await authController.resetPassword(
      resetToken: widget.resetToken,
      newPassword: password,
      confirmationPassword: confirmation,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF6FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E2EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.password_rounded,
                    size: 54,
                    color: Color(0xFF6B38D4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: Color(0xFF151124),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buat password baru untuk akun CompuPay kamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF7B7486),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const _Label('NEW PASSWORD'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: _passwordDecoration(
                      hintText: 'Enter new password',
                      hidden: hidePassword,
                      onToggle: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const _Label('CONFIRM PASSWORD'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: hideConfirmPassword,
                    decoration: _passwordDecoration(
                      hintText: 'Confirm new password',
                      hidden: hideConfirmPassword,
                      onToggle: () {
                        setState(
                          () => hideConfirmPassword = !hideConfirmPassword,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Password minimal 8 karakter, mengandung 1 huruf besar dan 1 karakter spesial.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF7B7486),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B38D4), Color(0xFF8455EF)],
                        ),
                      ),
                      child: TextButton(
                        onPressed: isLoading ? null : handleResetPassword,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1.2,
          color: Color(0xFF494454),
        ),
      ),
    );
  }
}

InputDecoration _passwordDecoration({
  required String hintText,
  required bool hidden,
  required VoidCallback onToggle,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7B7486)),
    suffixIcon: IconButton(
      onPressed: onToggle,
      icon: Icon(
        hidden ? Icons.visibility_off : Icons.visibility,
        color: const Color(0xFF7B7486),
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E2EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6B38D4)),
    ),
  );
}
