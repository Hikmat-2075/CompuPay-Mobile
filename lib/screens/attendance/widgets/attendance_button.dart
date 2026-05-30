import 'package:flutter/material.dart';

class TakeAttendancePhotoButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final String label;
  final IconData icon;
  final bool loading;

  const TakeAttendancePhotoButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.label = 'Ambil Foto Presensi',
    this.icon = Icons.camera_alt_rounded,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = enabled && !loading;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: active ? null : const Color(0xFFE5E7EB),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x338B5CF6),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: active ? Colors.white : const Color(0xFF9CA3AF), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
