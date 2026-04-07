import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.2),
                border: Border.all(
                  color: Color(0xFF6B38D4).withOpacity(0.2),
                  width: 4,
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 100,
                color: Color(0xFF6B38D4),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48,
                  ), // Gaya default
                  children: [
                    TextSpan(
                      text: 'Com',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text: 'p', // Kata yang ingin dibedakan warnanya
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
                      text: 'Pay', // Kata yang ingin dibedakan warnanya
                      style: TextStyle(
                        color: Color(0xFF6B38D4),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                'FINACIAL CONCIERGE',
                style: TextStyle(
                  color: Color(0XFF494454),
                  fontSize: 14,
                  letterSpacing: 2.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
