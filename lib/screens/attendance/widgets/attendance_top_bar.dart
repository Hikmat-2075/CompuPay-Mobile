import 'package:flutter/material.dart';
import 'package:compupay_mobile/shared/widgets/app_header.dart';

class AttendanceTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AttendanceTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  static const _primaryColor = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return const AppHeader(title: 'Attendance', showBackButton: false);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
