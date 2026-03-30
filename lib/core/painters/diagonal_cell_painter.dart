import 'package:flutter/material.dart';

/// CustomPainter that splits a cell diagonally (top-left / bottom-right)
/// to show two users' contribution levels on the same day.
///
/// ┌──────┐
/// │╲  P  │  P = Partner (bottom-right triangle)
/// │  ╲   │
/// │ U  ╲ │  U = User (top-left triangle)
/// └──────┘
class DiagonalCellPainter extends CustomPainter {
  /// Color for the top-left triangle (current user).
  final Color userColor;

  /// Color for the bottom-right triangle (partner).
  final Color partnerColor;

  /// Border radius for the cell.
  final double borderRadius;

  DiagonalCellPainter({
    required this.userColor,
    required this.partnerColor,
    this.borderRadius = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Clip to rounded rectangle
    canvas.save();
    canvas.clipRRect(rrect);

    // Top-left triangle (user)
    final userPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      userPath,
      Paint()
        ..color = userColor
        ..style = PaintingStyle.fill,
    );

    // Bottom-right triangle (partner)
    final partnerPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      partnerPath,
      Paint()
        ..color = partnerColor
        ..style = PaintingStyle.fill,
    );

    // Diagonal line separator
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(DiagonalCellPainter oldDelegate) =>
      userColor != oldDelegate.userColor ||
      partnerColor != oldDelegate.partnerColor;
}
