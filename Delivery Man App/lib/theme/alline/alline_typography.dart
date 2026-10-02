import 'package:flutter/material.dart';

abstract final class AllineTypography {
  static const fontFamily = 'AllineTajawal';
  static const displayLarge = TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const displayMedium = TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const titleLarge = TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const titleMedium = TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const titleSmall = TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const bodyLarge =
      TextStyle(fontFamily: fontFamily, fontSize: 16, height: 1.5);
  static const bodyMedium =
      TextStyle(fontFamily: fontFamily, fontSize: 14, height: 1.5);
  static const bodySmall =
      TextStyle(fontFamily: fontFamily, fontSize: 12, height: 1.5);
  static const labelLarge = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const labelMedium = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const labelSmall = TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const numericLarge = TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const numericMedium = TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      height: 1.4,
      fontWeight: FontWeight.w700);
  static const buttonLarge = labelLarge, buttonMedium = labelMedium;
  static const display = displayLarge,
      body = bodyMedium,
      caption = bodySmall,
      button = buttonLarge,
      numeric = numericMedium;
  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
      displayLarge: displayLarge.copyWith(color: primary),
      displayMedium: displayMedium.copyWith(color: primary),
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: primary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: labelLarge.copyWith(color: primary),
      labelMedium: labelMedium.copyWith(color: primary),
      labelSmall: labelSmall.copyWith(color: secondary));
}
