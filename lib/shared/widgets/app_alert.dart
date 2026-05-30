import 'package:flutter/material.dart';

enum AlertType {
  success,
  error,
  warning,
  info,
}

class AppAlert {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    AlertType type = AlertType.info,
  }) {
    late Color color;
    late IconData icon;

    switch (type) {
      case AlertType.success:
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        break;

      case AlertType.error:
        color = Colors.red;
        icon = Icons.cancel_rounded;
        break;

      case AlertType.warning:
        color = Colors.orange;
        icon = Icons.warning_rounded;
        break;

      case AlertType.info:
        color = Colors.blue;
        icon = Icons.info_rounded;
        break;
    }

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(
      const Duration(seconds: 3),
      () => entry.remove(),
    );
  }
}