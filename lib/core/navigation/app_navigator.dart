import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static void goToLogin() {
    key.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static void goToMain() {
    key.currentState?.pushNamedAndRemoveUntil('/main', (route) => false);
  }
}
