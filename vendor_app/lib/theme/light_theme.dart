import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

ThemeData light = ThemeData(
  fontFamily: 'AllineTajawal',
  primaryColor: AllineColors.primary,
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: AllineColors.coolGray,
  disabledColor: const Color(0xFF343A40),
  canvasColor: AllineColors.white,
  cardColor: AllineColors.white,
  splashColor: Colors.transparent,
  scaffoldBackgroundColor: AllineColors.softBlue,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AllineColors.navyText),
    bodyMedium: TextStyle(color: AllineColors.primary),
    bodySmall: TextStyle(color: AllineColors.coolGray),
    headlineMedium: TextStyle(color: AllineColors.navyText),
    headlineLarge: TextStyle(color: AllineColors.darkBlue),
  ),

  colorScheme: const ColorScheme.light(
    primary: AllineColors.primary,
    secondary: AllineColors.orange,
    error: AllineColors.error,
    tertiary: AllineColors.orange,
    tertiaryContainer: AllineColors.softBlue,
    onTertiaryContainer: AllineColors.success,
    primaryContainer: AllineColors.brightBlue,
    secondaryContainer: AllineColors.softBlue,
    surface: AllineColors.white,
    surfaceTint: AllineColors.primary,
    onPrimary: AllineColors.white,
    onSecondary: AllineColors.white,
    outline: AllineColors.border,
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);