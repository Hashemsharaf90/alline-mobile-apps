import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

ThemeData dark = ThemeData(
  fontFamily: 'AllineTajawal',
  primaryColor: AllineColors.primary,
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
  brightness: Brightness.dark,
  highlightColor: const Color(0xFF252525),
  hintColor: AllineColors.darkTextSub,
  disabledColor: const Color(0xFF64748B),
  canvasColor: AllineColors.darkSurface,
  cardColor: AllineColors.darkCard,
  splashColor: Colors.transparent,
  scaffoldBackgroundColor: AllineColors.darkScaffold,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AllineColors.darkText),
    bodyMedium: TextStyle(color: AllineColors.darkText),
    bodySmall: TextStyle(color: AllineColors.darkTextSub),
    headlineMedium: TextStyle(color: AllineColors.darkText),
    headlineLarge: TextStyle(color: AllineColors.darkText),
  ),

  colorScheme: const ColorScheme.dark(
    primary: AllineColors.primary,
    secondary: AllineColors.orange,
    error: AllineColors.error,
    tertiary: AllineColors.warning,
    tertiaryContainer: AllineColors.darkSurface,
    onTertiaryContainer: AllineColors.success,
    primaryContainer: AllineColors.brightBlue,
    secondaryContainer: AllineColors.darkCard,
    surface: AllineColors.darkCard,
    surfaceTint: AllineColors.primary,
    onPrimary: AllineColors.white,
    onSecondary: AllineColors.white,
    outline: AllineColors.darkBorder,
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
