import 'package:flutter/material.dart';

import 'package:compupay_mobile/core/services/auth_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';

import 'package:compupay_mobile/navigation/main_navigation.dart';

class AuthController {
  final BuildContext context;

  AuthController(this.context);

  Future<void> login(String email, String password) async {
    try {
      final res = await AuthService.login(email, password);

      // cek response API
      if (res.code == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(),
          ),
        );
      } else {
        _showError(res.message);
      }
    }

    // error dari API
    on ApiException catch (e) {
      _showError(e.message);
    }

    // error lain
    catch (e) {
      _showError("Terjadi kesalahan");
    }
  }

  Future<void> logout() async {
    await SessionService.logout();

    Navigator.pushReplacementNamed(context, "/login");
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}