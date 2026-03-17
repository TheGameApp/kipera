import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KiperaBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const KiperaBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap ?? () {
        if (Navigator.of(context).canPop()) {
          context.pop();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF6B21A8) : const Color(0xFFD6BBFC),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          size: 20,
          color: isDark ? Colors.white : null,
        ),
      ),
    );
  }
}
