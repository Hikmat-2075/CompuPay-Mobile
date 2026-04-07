import 'package:compupay_mobile/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay 3 detik lalu pindah ke LoginScreen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.2),
                border: Border.all(
                  color: const Color(0xFF6B38D4).withOpacity(0.2),
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 100,
                color: Color(0xFF6B38D4),
              ),
            ),
          ),

          const SizedBox(height: 20),

          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 48),
              children: [
                TextSpan(
                  text: 'Com',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: 'p',
                  style: TextStyle(
                    color: Color(0xFF6B38D4),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: 'u',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: 'Pay',
                  style: TextStyle(
                    color: Color(0xFF6B38D4),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'FINANCIAL CONCIERGE',
            style: TextStyle(
              color: Color(0XFF494454),
              fontSize: 14,
              letterSpacing: 2.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
