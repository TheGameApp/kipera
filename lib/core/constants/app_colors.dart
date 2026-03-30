import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const purple = Color(0xFFA855F7);
  static const purpleLight = Color(0xFFD6BBFC);
  static const pink = Color(0xFFEC4899);
  static const pinkLight = Color(0xFFFCDCE1);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFD9E6B9);
  static const warning = Color(0xFFEAB308);
  static const warningLight = Color(0xFFFDF5D0);
  static const info = Color(0xFF06B6D4);
  static const infoLight = Color(0xFFD2EEF4);

  // Light theme
  static const backgroundLight = Color(0xFFFAFAFA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const inputBgLight = Color(0xFFF5F5F5);
  static const textLight = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const borderLight = Color(0xFFE0E0E0);

  // Dark theme
  static const backgroundDark = Color(0xFF141414);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF2A2A2A);
  static const inputBgDark = Color(0xFF2A2A2A);
  static const textDark = Color(0xFFF0F0F0);
  static const borderDark = Color(0xFF333333);

  // Heatmap Light
  static const heatmapLight0 = Color(0xFFF3F4F6);
  static const heatmapLight1 = Color(0xFFFCE4EC); // pink tint
  static const heatmapLight2 = Color(0xFFF8BBD0);
  static const heatmapLight3 = Color(0xFFE0CFFC);
  static const heatmapLight4 = Color(0xFFA855F7);

  // Heatmap Dark
  static const heatmapDark0 = Color(0xFF374151);
  static const heatmapDark1 = Color(0xFF6B21A8);
  static const heatmapDark2 = Color(0xFF7C3AED);
  static const heatmapDark3 = Color(0xFF8B5CF6);
  static const heatmapDark4 = Color(0xFFA78BFA);

  // Heatmap Partner Light (pink/rose palette)
  static const heatmapPartnerLight0 = Color(0xFFF3F4F6);
  static const heatmapPartnerLight1 = Color(0xFFFCE4EC);
  static const heatmapPartnerLight2 = Color(0xFFF48FB1);
  static const heatmapPartnerLight3 = Color(0xFFEC407A);
  static const heatmapPartnerLight4 = Color(0xFFD81B60);

  // Heatmap Partner Dark (pink/rose palette)
  static const heatmapPartnerDark0 = Color(0xFF374151);
  static const heatmapPartnerDark1 = Color(0xFF880E4F);
  static const heatmapPartnerDark2 = Color(0xFFC2185B);
  static const heatmapPartnerDark3 = Color(0xFFE91E63);
  static const heatmapPartnerDark4 = Color(0xFFF06292);

  // Goal/Habit Card Pastel Colors (from ref: pink, sage, peach, cream, sky)
  static const goalColors = [
    Color(0xFFFCDCE1), // Pink
    Color(0xFFD9E6B9), // Sage Green
    Color(0xFFFDD5B1), // Peach/Orange
    Color(0xFFFDF5D0), // Cream/Yellow
    Color(0xFFD2EEF4), // Sky Blue
    Color(0xFFE0CFFC), // Lavender
  ];

  // Named color palette for color picker (from ref screenshot)
  static const namedColors = {
    'Purple': Color(0xFFD6BBFC),
    'Pink': Color(0xFFF8BBD0),
    'Yellow': Color(0xFFFFF9C4),
    'Green': Color(0xFFC8E6C9),
    'Blue': Color(0xFFBBDEFB),
    'Red': Color(0xFFEF9A9A),
    'Orange': Color(0xFFFFCC80),
    'D.Green': Color(0xFF81C784),
    'D.Purple': Color(0xFFB39DDB),
    'L.Pink': Color(0xFFF48FB1),
    'D.Red': Color(0xFFE57373),
    'L.Yellow': Color(0xFFFFF59D),
    'L.Green': Color(0xFFA5D6A7),
    'L.Purple': Color(0xFFCE93D8),
  };

  // ── Legacy aliases (keep existing code compiling) ──
  static const primary = purple;
  static const primaryContainer = purpleLight;
  static const secondary = pink;
  static const secondaryContainer = pinkLight;
  static const successContainer = successLight;
  static const warningContainer = warningLight;
  static const infoContainer = infoLight;
  static const textPrimary = textLight;
  static const primaryDark = Color(0xFFA78BFA);
  static const primaryContainerDark = Color(0xFF2D1B4E);
  static const textPrimaryDark = textDark;
}
