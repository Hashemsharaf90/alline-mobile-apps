import 'package:flutter/material.dart';

Color _primaryColor = const Color(0xFF2563EB);
Color _secondaryColor = const Color(0xFF1D4ED8);

ThemeData dark = ThemeData(
  fontFamily: 'TitilliumWeb',
  primaryColor: _primaryColor,
  brightness: Brightness.dark,
  highlightColor: const Color(0xFF334155),
  hintColor: const Color(0xFF64748B),
  cardColor: const Color(0xFF1E293B),
  scaffoldBackgroundColor: const Color(0xFF0F172A),
  splashColor: Colors.transparent,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),  // Text color primary
    bodyMedium: TextStyle(color: Color(0xFFE2E8F0)), // Text color Secondary
    bodySmall: TextStyle(color: Color(0xFF94A3B8)),  // Text color Light grey
    titleMedium: TextStyle(color: Color(0xFFCBD5E1)),
  ),

  colorScheme : ColorScheme.dark(
    primary: _primaryColor,  // Primary Color
    secondary: _secondaryColor,  // Secondary Color
    tertiary: const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: const Color(0xFF1E3A8A),
    surface: const Color(0xFF1E293B),
    onPrimary: const Color(0xFF93C5FD),
    onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
    primaryContainer: const Color(0xFF1E3A8A),
    onSecondaryContainer: const Color(0xFF1E293B),
    outline: const Color(0xFF3B82F6), // Info Color
    onTertiary: const Color(0xFF334155),
    secondaryContainer: const Color(0xFF334155),
    surfaceContainer: const Color(0xFF334155),
    error: const Color(0xFFFF4040), // Danger Color
    shadow: const Color(0xFF000000),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);