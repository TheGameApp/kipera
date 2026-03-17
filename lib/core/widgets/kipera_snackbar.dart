import 'package:flutter/material.dart';

enum KiperaSnackType { success, warning, error, info }

class KiperaSnackBar {
  KiperaSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    KiperaSnackType type = KiperaSnackType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (Color bgColor, Color fgColor, IconData defaultIcon) = switch (type) {
      KiperaSnackType.success => (
          const Color(0xFF16A34A),
          Colors.white,
          Icons.check_circle_rounded,
        ),
      KiperaSnackType.warning => (
          const Color(0xFFF59E0B),
          const Color(0xFF1A1A2E),
          Icons.warning_amber_rounded,
        ),
      KiperaSnackType.error => (
          const Color(0xFFEF4444),
          Colors.white,
          Icons.error_rounded,
        ),
      KiperaSnackType.info => (
          const Color(0xFFA855F7),
          Colors.white,
          Icons.info_rounded,
        ),
    };

    final usedIcon = icon ?? defaultIcon;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(usedIcon, color: fgColor.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: fgColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bgColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}
