import 'package:flutter/material.dart';

/// The authoritative Alline brand palette.
///
/// Screens should prefer [Theme.of] and [AllineThemeColors.of] for semantic
/// colors. These constants are intended for theme construction, brand assets,
/// and the small number of places that cannot access a [BuildContext].
abstract final class AllineColors {
  static const Color primary = Color(0xFF015FC9);
  static const Color primaryDark = Color(0xFF032C75);
  static const Color brightBlue = Color(0xFF1675D1);
  static const Color priceBlue = Color(0xFF0B4FA3);
  static const Color interactionBlue = Color(0xFF006DDF);
  static const Color accent = Color(0xFFEC970D);
  static const Color textPrimary = Color(0xFF071B49);
  static const Color textSecondary = Color(0xFF6D85AF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F8FE);
  static const Color border = Color(0xFFE1E8F2);
  static const Color success = Color(0xFF18A957);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD9363E);

  // Premium navy dark mode palette. This deliberately avoids pure black and
  // is used by the semantic dark theme across the application.
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111B2E);
  static const Color darkSurfaceElevated = Color(0xFF162238);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFF9EACC1);
  static const Color darkBorder = Color(0xFF22314A);
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkBrightBlue = Color(0xFF60A5FA);
  static const Color darkAccent = Color(0xFFF59E0B);
}
