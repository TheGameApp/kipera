import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

const _fontFamily = 'ClashDisplay';
const _bodyFontFamily = 'ClashDisplay';

class KiperaColors extends ThemeExtension<KiperaColors> {
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final List<Color> heatmapColors;
  final List<Color> goalCardColors;

  const KiperaColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.heatmapColors,
    required this.goalCardColors,
  });

  @override
  KiperaColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    List<Color>? heatmapColors,
    List<Color>? goalCardColors,
  }) {
    return KiperaColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      heatmapColors: heatmapColors ?? this.heatmapColors,
      goalCardColors: goalCardColors ?? this.goalCardColors,
    );
  }

  @override
  KiperaColors lerp(KiperaColors? other, double t) {
    if (other is! KiperaColors) return this;
    return KiperaColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      heatmapColors: heatmapColors,
      goalCardColors: goalCardColors,
    );
  }

  static const light = KiperaColors(
    success: AppColors.success,
    successContainer: AppColors.successLight,
    warning: AppColors.warning,
    warningContainer: AppColors.warningLight,
    info: AppColors.info,
    infoContainer: AppColors.infoLight,
    heatmapColors: [
      AppColors.heatmapLight0,
      AppColors.heatmapLight1,
      AppColors.heatmapLight2,
      AppColors.heatmapLight3,
      AppColors.heatmapLight4,
    ],
    goalCardColors: AppColors.goalColors,
  );

  static const dark = KiperaColors(
    success: AppColors.success,
    successContainer: Color(0xFF1A3D2A),
    warning: AppColors.warning,
    warningContainer: Color(0xFF3D3A1A),
    info: AppColors.info,
    infoContainer: Color(0xFF1A2E3D),
    heatmapColors: [
      AppColors.heatmapDark0,
      AppColors.heatmapDark1,
      AppColors.heatmapDark2,
      AppColors.heatmapDark3,
      AppColors.heatmapDark4,
    ],
    goalCardColors: [
      Color(0xFF3D1B2E), // Pink (dark)
      Color(0xFF1E3D1B), // Sage (dark)
      Color(0xFF3D2E1B), // Peach (dark)
      Color(0xFF3D3A1B), // Cream (dark)
      Color(0xFF1B2E3D), // Sky (dark)
      Color(0xFF2D1B4E), // Lavender (dark)
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Text theme
// ─────────────────────────────────────────────────────────────────────────────

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    // Headlines → ClashDisplay Bold (700)
    displayLarge: base.displayLarge?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    displayMedium: base.displayMedium?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    displaySmall: base.displaySmall?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    headlineLarge: base.headlineLarge?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    // Titles → ClashDisplay Medium/Semibold (500-600)
    titleLarge: base.titleLarge?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
    titleMedium: base.titleMedium?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
    titleSmall: base.titleSmall?.copyWith(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
    // Body → ClashDisplay Light/Regular (300-400)
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: _bodyFontFamily, fontWeight: FontWeight.w400),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: _bodyFontFamily, fontWeight: FontWeight.w400),
    bodySmall: base.bodySmall?.copyWith(fontFamily: _bodyFontFamily, fontWeight: FontWeight.w300),
    // Labels → ClashDisplay Light/Regular (300-400)
    labelLarge: base.labelLarge?.copyWith(fontFamily: _bodyFontFamily, fontWeight: FontWeight.w400),
    labelMedium: base.labelMedium?.copyWith(fontFamily: _bodyFontFamily, fontWeight: FontWeight.w400),
    labelSmall: base.labelSmall?.copyWith(fontFamily: _bodyFontFamily, fontWeight: FontWeight.w300),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Light theme
// ─────────────────────────────────────────────────────────────────────────────

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
      primaryContainer: AppColors.purpleLight,
      secondary: AppColors.pink,
      secondaryContainer: AppColors.pinkLight,
      surface: AppColors.surfaceLight,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.textLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: _buildTextTheme(base.textTheme),

    // AppBar — no elevation, left-aligned title
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
    ),

    // Cards — elevation 0, borderRadius 16
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ElevatedButton — dark bg (#1A1A2E), white text, full-width feel
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textLight,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _bodyFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // OutlinedButton — thin border, borderRadius 16
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),

    // Input fields — filled gray, thin border, borderRadius 12
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBgLight,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: _bodyFontFamily,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Bottom nav — dark/black background, purple accent
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.textLight,
      selectedItemColor: AppColors.purple,
      unselectedItemColor: Color(0xFF9E9E9E),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // FAB — purple, for centered bottom nav action
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
    ),

    extensions: const [KiperaColors.light],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark theme
// ─────────────────────────────────────────────────────────────────────────────

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.dark,
      primary: AppColors.purple,
      primaryContainer: const Color(0xFF2D1B4E),
      secondary: AppColors.pink,
      surface: AppColors.surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.textDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: _buildTextTheme(base.textTheme),

    // AppBar — no elevation, left-aligned title
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    ),

    // Cards — elevation 0, borderRadius 16
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ElevatedButton — white bg, black text (inverted from light)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textDark,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _bodyFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // OutlinedButton — thin border, borderRadius 16
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: AppColors.borderDark),
      ),
    ),

    // Input fields — filled dark, thin border, borderRadius 12
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBgDark,
      hintStyle: TextStyle(
        color: AppColors.textDark.withValues(alpha: 0.3),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: _bodyFontFamily,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Bottom nav — light bg in dark mode
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.textDark,
      selectedItemColor: AppColors.purple,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // FAB — purple
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Bottom sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
    ),

    extensions: const [KiperaColors.dark],
  );
}
