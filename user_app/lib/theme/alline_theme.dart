import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_typography.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

abstract final class AllineTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final semantic = isDark ? AllineThemeColors.dark : AllineThemeColors.light;
    final primary = isDark ? AllineColors.darkPrimary : AllineColors.primary;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: AllineColors.white,
      primaryContainer:
          isDark ? AllineColors.darkSurfaceElevated : const Color(0xFFE7F0FC),
      onPrimaryContainer: semantic.textPrimary,
      secondary: isDark ? AllineColors.darkAccent : AllineColors.accent,
      onSecondary:
          isDark ? AllineColors.darkBackground : AllineColors.textPrimary,
      secondaryContainer:
          isDark ? const Color(0xFF4C3812) : const Color(0xFFFFF4DF),
      onSecondaryContainer: semantic.textPrimary,
      tertiary: isDark ? AllineColors.darkBrightBlue : AllineColors.brightBlue,
      onTertiary: AllineColors.white,
      tertiaryContainer:
          isDark ? AllineColors.darkSurfaceElevated : AllineColors.background,
      onTertiaryContainer: semantic.textPrimary,
      error: AllineColors.error,
      onError: AllineColors.white,
      errorContainer:
          isDark ? const Color(0xFF5B2028) : const Color(0xFFFFECEE),
      onErrorContainer: semantic.textPrimary,
      surface: semantic.surface,
      onSurface: semantic.textPrimary,
      surfaceContainerHighest: semantic.surfaceElevated,
      onSurfaceVariant: semantic.textSecondary,
      outline: semantic.border,
      outlineVariant: semantic.border.withValues(alpha: .65),
      shadow: isDark
          ? Colors.transparent
          : AllineColors.primaryDark.withValues(alpha: .10),
      scrim: AllineColors.primaryDark.withValues(alpha: .54),
      inverseSurface: isDark ? AllineColors.white : AllineColors.primaryDark,
      onInverseSurface: isDark ? AllineColors.textPrimary : AllineColors.white,
      inversePrimary:
          isDark ? AllineColors.darkPrimary : AllineColors.brightBlue,
      surfaceTint: primary,
    );

    final textTheme = AllineTypography.textTheme(
        semantic.textPrimary, semantic.textSecondary);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AllineRadius.input),
      borderSide: BorderSide(color: semantic.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AllineTypography.fontFamily,
      colorScheme: scheme,
      primaryColor: primary,
      scaffoldBackgroundColor: semantic.background,
      cardColor: semantic.surface,
      canvasColor: semantic.background,
      dividerColor: semantic.border,
      disabledColor: semantic.textSecondary.withValues(alpha: .42),
      hintColor: semantic.textSecondary,
      highlightColor: primary.withValues(alpha: .08),
      splashColor: primary.withValues(alpha: .08),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[semantic],
      iconTheme: IconThemeData(color: semantic.textSecondary),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.surface,
        foregroundColor: semantic.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 56,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: semantic.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: semantic.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: semantic.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.card),
          side: BorderSide(color: semantic.border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: semantic.textSecondary,
        textColor: semantic.textPrimary,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: semantic.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.control),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: semantic.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.surface,
        constraints: const BoxConstraints(minHeight: 54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: semantic.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: semantic.textPrimary),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: primary),
        errorStyle: textTheme.bodySmall?.copyWith(color: semantic.error),
        prefixIconColor: semantic.textSecondary,
        suffixIconColor: semantic.textSecondary,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: semantic.border.withValues(alpha: .55)),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: semantic.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: semantic.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, AllineTouchTarget.buttonHeight),
          backgroundColor: primary,
          foregroundColor: AllineColors.white,
          disabledBackgroundColor: semantic.border,
          disabledForegroundColor: semantic.textSecondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AllineRadius.button),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, AllineTouchTarget.buttonHeight),
          backgroundColor: primary,
          foregroundColor: AllineColors.white,
          disabledBackgroundColor: semantic.border,
          disabledForegroundColor: semantic.textSecondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AllineRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          foregroundColor: primary,
          side: BorderSide(color: semantic.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: textTheme.labelLarge?.copyWith(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AllineRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: AllineTouchTarget.minimumSize,
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: textTheme.labelMedium?.copyWith(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AllineRadius.control),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: AllineTouchTarget.minimumSize,
          foregroundColor: semantic.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AllineRadius.control),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: semantic.border, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return semantic.border;
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AllineColors.white),
      ),
      radioTheme: RadioThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return semantic.border;
          if (states.contains(WidgetState.selected)) return primary;
          return semantic.textSecondary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AllineColors.white
                : semantic.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : semantic.border),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: semantic.surface,
        selectedColor: primary.withValues(alpha: .12),
        disabledColor: semantic.border.withValues(alpha: .5),
        side: BorderSide(color: semantic.border),
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.control),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: semantic.textSecondary,
        indicatorColor: primary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        dividerColor: semantic.border,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: semantic.border,
        circularTrackColor: semantic.border,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AllineColors.white,
        elevation: isDark ? 0 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.button),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: semantic.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.card),
          side: BorderSide(color: semantic.border),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: semantic.textSecondary,
        collapsedIconColor: semantic.textSecondary,
        textColor: semantic.textPrimary,
        collapsedTextColor: semantic.textPrimary,
        backgroundColor: semantic.surface,
        collapsedBackgroundColor: semantic.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AllineColors.darkSurfaceElevated
            : AllineColors.primaryDark,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AllineColors.white),
        actionTextColor: AllineColors.white,
        elevation: 4,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.input),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: semantic.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 8,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AllineRadius.cardLarge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.surfaceElevated,
        modalBackgroundColor: semantic.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AllineRadius.hero),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: semantic.surface,
        selectedItemColor: primary,
        unselectedItemColor: semantic.textSecondary,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: semantic.surface,
        indicatorColor: primary.withValues(alpha: .10),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => textTheme.labelSmall!.copyWith(
                  color: states.contains(WidgetState.selected)
                      ? primary
                      : semantic.textSecondary,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? primary
                  : semantic.textSecondary,
              size: 23,
            )),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
