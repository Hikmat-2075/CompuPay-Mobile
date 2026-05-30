import 'package:url_launcher/url_launcher.dart';

class ContactHR {
  static Future<void> openWhatsApp() async {
    final url = Uri.parse(
      'https://wa.me/6281234567890?text=Halo%20HR,%20saya%20membutuhkan%20bantuan%20terkait%20akun%20CompuPay.',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}