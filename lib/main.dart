import 'package:compupay_mobile/navigation/main_navigation.dart';
import 'package:compupay_mobile/screens/login/login_screen.dart';
import 'package:compupay_mobile/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); // 🔥 WAJIB

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompuPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        "/login": (_) => const LoginScreen(),
        "/main": (_) => const MainNavigation(),
      },
    );
  }
}
