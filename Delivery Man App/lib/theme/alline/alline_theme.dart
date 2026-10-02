import 'package:flutter/material.dart';
import 'alline_colors.dart';
import 'alline_typography.dart';
import 'alline_tokens.dart';

ThemeData buildAllineTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? AllineColors.surfaceDark : AllineColors.surfaceLight;
  final background =
      dark ? AllineColors.backgroundDark : AllineColors.backgroundLight;
  final text = dark ? AllineColors.primaryTextDark : AllineColors.primaryText;
  final muted =
      dark ? AllineColors.secondaryTextDark : AllineColors.secondaryText;
  final border = dark ? AllineColors.borderDark : AllineColors.borderLight;
  final scheme = ColorScheme.fromSeed(
          seedColor: AllineColors.primaryBlue, brightness: brightness)
      .copyWith(
          primary: dark ? AllineColors.brightBlue : AllineColors.primaryBlue,
          onPrimary: AllineColors.surfaceLight,
          secondary: AllineColors.brightBlue,
          tertiary: AllineColors.warning,
          error: AllineColors.error,
          surface: surface,
          onSurface: text,
          onSurfaceVariant: muted,
          outline: border,
          primaryContainer: background,
          secondaryContainer: surface,
          tertiaryContainer: background,
          onTertiaryContainer: AllineColors.success);
  final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AllineRadius.control));
  return ThemeData(
      brightness: brightness,
      fontFamily: AllineTypography.fontFamily,
      primaryColor: scheme.primary,
      primaryColorDark: AllineColors.darkBlue,
      primaryColorLight: AllineColors.brightBlue,
      hintColor: muted,
      shadowColor: border,
      dividerColor: border,
      cardColor: surface,
      canvasColor: surface,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      textTheme: AllineTypography.textTheme(text, muted),
      appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: text,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true),
      cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: AllineRadius.cardBorder,
              side: BorderSide(color: border))),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.all(AllineSpacing.lg),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AllineRadius.control)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AllineRadius.control),
              borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AllineRadius.control),
              borderSide: BorderSide(color: scheme.primary, width: 2))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              minimumSize: const Size(44, 52),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: AllineTypography.buttonLarge,
              shape: shape,
              elevation: 0)),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(44, 52),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: AllineTypography.buttonLarge,
              shape: shape,
              side: BorderSide(color: border))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              textStyle: AllineTypography.buttonMedium)),
      dialogTheme: DialogThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AllineRadius.hero))),
      bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: surface,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AllineRadius.hero)))),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: scheme.primary.withValues(alpha: .12),
          labelTextStyle: WidgetStatePropertyAll(
              AllineTypography.labelSmall.copyWith(color: text))));
}
