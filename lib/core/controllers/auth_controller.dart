import 'package:flutter/material.dart';

import 'package:compupay_mobile/core/services/auth_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/shared/widgets/app_alert.dart';

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
    AppAlert.show(context, title: 'Oops!', message: msg, type: AlertType.error);
  }

  Future<bool> forgetPassword(String email) async {
    try {
      await AuthService.forgetPassword(email);
      _showSuccess('OTP berhasil dikirim ke email');
      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } catch (_) {
      _showError('Terjadi kesalahan');
      return false;
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    try {
      final result = await AuthService.verifyOtp(email, otp);

      if (result.resetToken.isEmpty) {
        _showError('Reset token tidak ditemukan');
        return null;
      }

      _showSuccess('OTP berhasil diverifikasi');
      return result.resetToken;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    } catch (_) {
      _showError('Terjadi kesalahan');
      return null;
    }
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmationPassword,
  }) async {
    try {
      await AuthService.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmationPassword: confirmationPassword,
      );

      _showSuccess('Password berhasil direset');
      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } catch (_) {
      _showError('Terjadi kesalahan');
      return false;
    }
  }

  void _showSuccess(String msg) {
    AppAlert.show(
      context,
      title: 'Success',
      message: msg,
      type: AlertType.success,
    );
  }
}
