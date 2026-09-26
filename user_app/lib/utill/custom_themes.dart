import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_typography.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

const titilliumRegular = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontSize: 12,
);
const titleRegular = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontWeight: FontWeight.w500,
  fontSize: 14,
);
const titleHeader = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontWeight: FontWeight.w600,
  fontSize: 16,
);
const titilliumSemiBold = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

const titilliumBold = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontSize: 14,
  fontWeight: FontWeight.w700,
);
const titilliumItalic = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontSize: 14,
  fontStyle: FontStyle.italic,
);

const textRegular = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 14,
);

const textMedium = TextStyle(
    fontFamily: AllineTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500);
const textBold = TextStyle(
    fontFamily: AllineTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600);

const robotoBold = TextStyle(
  fontFamily: AllineTypography.fontFamily,
  fontSize: 14,
  fontWeight: FontWeight.w700,
);

class ThemeShadow {
  static List<BoxShadow> getShadow(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    List<BoxShadow> boxShadow = [
      BoxShadow(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : colors.textPrimary.withValues(alpha: .07),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      )
    ];
    return boxShadow;
  }
}
