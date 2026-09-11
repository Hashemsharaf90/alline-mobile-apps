import 'package:flutter/material.dart';

Color _primaryColor = const Color(0xFF1455AC);
Color _secondaryColor = const Color(0xFF0F3A7A);


ThemeData light({Color? primaryColor, Color? secondaryColor})=> ThemeData(
  fontFamily: 'TitilliumWeb',
  primaryColor: primaryColor ?? _primaryColor,
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: const Color(0xFF94A3B8), //Border Color
  splashColor: Colors.transparent,
  cardColor: Colors.white,

  scaffoldBackgroundColor: const Color(0xFFF8FAFC),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF0F172A)),  // Text color primary
    bodyMedium: TextStyle(color: Color(0xFF334155)), // Text color Secondary
    bodySmall: TextStyle(color: Color(0xFF64748B)),  // Text color Light grey
    titleMedium: TextStyle(color: Color(0xFF475569)),
  ),

  colorScheme: ColorScheme.light(
    primary: primaryColor ?? _primaryColor,  // Primary Color
    secondary: secondaryColor ?? _secondaryColor,  // Secondary Color
    tertiary: const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: const Color(0xFFDBEAFE),
    onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
    onPrimary: const Color(0xFF93C5FD),
    surface: Colors.white,
    onSecondary: secondaryColor ?? _secondaryColor,
    error: const Color(0xFFFF4040), // Danger Color
    onSecondaryContainer: const Color(0xFFEFF6FF),
    outline: const Color(0xFF1455AC), // Info Color
    onTertiary: const Color(0xFFEFF6FF),
    shadow: const Color(0xFF64748B),

    primaryContainer: const Color(0xFFDBEAFE),
    secondaryContainer: const Color(0xFFF1F5F9),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
