import 'package:flutter/material.dart';

class AttendanceTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AttendanceTopBar({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  static const _primaryColor = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 8,

      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(
          Icons.arrow_back,
          color: _primaryColor,
        ),
      ),

      title: const Text(
        "Attendance",
        style: TextStyle(
          color: _primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(
            Icons.more_vert,
            color: Color(0xFF494454),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}