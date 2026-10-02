import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';

@immutable
class AllineThemeColors extends ThemeExtension<AllineThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color skeletonBase;
  final Color skeletonHighlight;

  const AllineThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  static const light = AllineThemeColors(
    background: AllineColors.background,
    surface: AllineColors.white,
    surfaceElevated: AllineColors.white,
    textPrimary: AllineColors.textPrimary,
    textSecondary: AllineColors.textSecondary,
    border: AllineColors.border,
    accent: AllineColors.accent,
    success: AllineColors.success,
    warning: AllineColors.warning,
    error: AllineColors.error,
    skeletonBase: Color(0xFFE8EEF7),
    skeletonHighlight: Color(0xFFF7FAFE),
  );

  static const dark = AllineThemeColors(
    background: AllineColors.darkBackground,
    surface: AllineColors.darkSurface,
    surfaceElevated: AllineColors.darkSurfaceElevated,
    textPrimary: AllineColors.darkTextPrimary,
    textSecondary: AllineColors.darkTextSecondary,
    border: AllineColors.darkBorder,
    accent: AllineColors.darkAccent,
    success: AllineColors.success,
    warning: AllineColors.warning,
    error: AllineColors.error,
    skeletonBase: Color(0xFF1A2941),
    skeletonHighlight: Color(0xFF223653),
  );

  static AllineThemeColors of(BuildContext context) {
    return Theme.of(context).extension<AllineThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AllineThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return AllineThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  AllineThemeColors lerp(
      covariant ThemeExtension<AllineThemeColors>? other, double t) {
    if (other is! AllineThemeColors) return this;
    return AllineThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}

extension AllineThemeContext on BuildContext {
  AllineThemeColors get allineColors => AllineThemeColors.of(this);
}
