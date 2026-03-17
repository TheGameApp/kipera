import 'package:flutter/material.dart';

class KiperaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  const KiperaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    if (outlined) {
      return icon != null
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(icon),
              label: child,
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            );
    }

    return icon != null
        ? ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: Icon(icon),
            label: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          );
  }
}
