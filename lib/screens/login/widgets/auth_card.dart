import 'package:compupay_mobile/screens/login/widgets/bottom_action.dart';
import 'package:compupay_mobile/screens/login/widgets/logo_section.dart';
import 'package:flutter/material.dart';
import 'login_form.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({super.key});

  Future<void> _openWhatsAppHR() async {
    const phone = '6281218116805';

    final url = Uri.parse(
      'https://wa.me/$phone?text=Halo%20HR,%20saya%20membutuhkan%20bantuan%20terkait%20akun%20CompuPay.',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      height: 631.5,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            children: [LogoSection(), SizedBox(height: 39.5), LoginForm()],
          ),
          BottomAction(onContactHR: _openWhatsAppHR),
        ],
      ),
    );
  }
}
