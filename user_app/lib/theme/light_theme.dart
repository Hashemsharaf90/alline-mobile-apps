import 'package:flutter/material.dart';

Color _primaryColor = const Color(0xFF0D9488);
Color _secondaryColor = const Color(0xFF0F766E);


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
    tertiaryContainer: const Color(0xFFCCFBF1),
    onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
    onPrimary: const Color(0xFF99F6E4),
    surface: Colors.white,
    onSecondary: secondaryColor ?? _secondaryColor,
    error: const Color(0xFFFF4040), // Danger Color
    onSecondaryContainer: const Color(0xFFF0FDFA),
    outline: const Color(0xFF0D9488), // Info Color
    onTertiary: const Color(0xFFF0FDFA),
    shadow: const Color(0xFF64748B),

    primaryContainer: const Color(0xFFCCFBF1),
    secondaryContainer: const Color(0xFFF1F5F9),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
