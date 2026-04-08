import 'package:compupay_mobile/screens/payslip/payslip_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B3EEA)),
      ),
      debugShowCheckedModeBanner: false,
      home: const PayslipScreen(),
    );
  }
}
