import 'package:flutter/material.dart';

import 'package:compupay_mobile/core/services/auth_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';

class AuthController {
  final BuildContext context;

  AuthController(this.context);

  Future<bool> login(String email, String password) async {
    try {
      final res = await AuthService.login(email, password);

      if (res.code == 200) {
        return true;
      }

      _showError(res.message);
      return false;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } catch (e) {
      _showError("Terjadi kesalahan");
      return false;
    }
  }

  Future<void> logout() async {
    await SessionService.logout();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
