import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
