import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/controllers/auth_controller.dart';
import 'package:compupay_mobile/screens/login/reset_password_screen.dart';
import 'package:compupay_mobile/shared/widgets/app_alert.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final otpController = TextEditingController();
  late AuthController authController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authController = AuthController(context);
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> handleVerifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      AppAlert.warning(
        context,
        message: 'OTP harus 6 digit.',
      );
      return;
    }

    setState(() => isLoading = true);

    final resetToken = await authController.verifyOtp(widget.email, otp);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (resetToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(resetToken: resetToken),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SimpleAuthScaffold(
      icon: Icons.verified_user_outlined,
      title: 'Verify OTP',
      subtitle: 'Masukkan kode OTP yang dikirim ke ${widget.email}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Label('OTP CODE'),
          const SizedBox(height: 6),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: _inputDecoration(
              hintText: 'Enter 6 digit OTP',
              icon: Icons.pin_outlined,
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            text: 'Verify OTP',
            isLoading: isLoading,
            onPressed: isLoading ? null : handleVerifyOtp,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class _SimpleAuthScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SimpleAuthScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
                  Icon(icon, size: 54, color: const Color(0xFF6B38D4)),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: Color(0xFF151124),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF7B7486),
                    ),
                  ),
                  const SizedBox(height: 32),
                  child,
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
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.2,
        color: Color(0xFF494454),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String hintText,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hintText,
    counterText: '',
    prefixIcon: Icon(icon, color: const Color(0xFF7B7486)),
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

class _PrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF6B38D4), Color(0xFF8455EF)],
          ),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
