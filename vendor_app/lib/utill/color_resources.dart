import 'package:flutter/material.dart';

class AllineColors {
  // Brand Blues
  static const Color primary = Color(0xFF015FC9); // Alline Blue 600
  static const Color primaryDark = Color(0xFF032C75); // Alline Blue 900
  static const Color secondary = Color(0xFF032C75);
  static const Color darkBlue = Color(0xFF032C75);
  static const Color brightBlue = Color(0xFF1675D1);
  static const Color accent = Color(0xFF1675D1);

  // Accent & Brand Colors
  static const Color orange = Color(0xFFEC970D); // Alline Orange
  static const Color highlight = Color(0xFFEC970D);
  static const Color orangeAccent = Color(0xFFFF6B00);

  // Typography Colors
  static const Color navyText = Color(0xFF071B49); // Primary text light
  static const Color textDark = Color(0xFF071B49);
  static const Color coolGray = Color(0xFF6D85AF); // Secondary text light
  static const Color textLight = Color(0xFF6D85AF);

  // Surface & Background Colors (Light)
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color softBlue = Color(0xFFF4F8FE); // Background light
  static const Color backgroundLight = Color(0xFFF4F8FE);
  static const Color border = Color(0xFFE1E8F2); // Subtle borders
  static const Color borderLight = Color(0xFFE1E8F2);

  // Surface & Background Colors (Dark)
  static const Color darkScaffold = Color(0xFF0B132B);
  static const Color darkSurface = Color(0xFF1C2541);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSub = Color(0xFF94A3B8);

  // Semantic Status Colors
  static const Color success = Color(0xFF18A957); // Green
  static const Color error = Color(0xFFD9363E); // Red
  static const Color danger = Color(0xFFD9363E);
  static const Color warning = Color(0xFFF59E0B); // Amber
}

class ColorResources {
  static Color getPrimary(BuildContext context) => AllineColors.primary;
  static Color getSecondary(BuildContext context) => AllineColors.orange;

  static Color getTextTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AllineColors.darkText
          : AllineColors.navyText;

  static Color getTextSubTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AllineColors.darkTextSub
          : AllineColors.coolGray;

  static Color getCardBg(BuildContext context) => Theme.of(context).cardColor;

  static Color getScaffoldBg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color getBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AllineColors.darkBorder
          : AllineColors.border;

  static Color getSuccess(BuildContext context) => AllineColors.success;
  static Color getError(BuildContext context) => AllineColors.error;
  static Color getWarning(BuildContext context) => AllineColors.warning;
}
