import 'package:flutter/material.dart';
import 'package:compupay_mobile/screens/home/home_screen.dart'; // sesuaikan path kamu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CompuPay',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C4AF2)),
      ),
      home: const HomeScreen(),
    );
  }
}