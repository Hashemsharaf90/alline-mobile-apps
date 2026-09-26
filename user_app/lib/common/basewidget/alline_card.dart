import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

enum AllineCardVariant { flat, outlined, elevated, action }

class AllineCard extends StatelessWidget {
  final Widget child;
  final AllineCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double radius;

  const AllineCard({
    super.key,
    required this.child,
    this.variant = AllineCardVariant.outlined,
    this.padding = const EdgeInsets.all(AllineSpacing.md),
    this.margin,
    this.onTap,
    this.radius = AllineRadius.card,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = BoxDecoration(
      color: variant == AllineCardVariant.action
          ? Theme.of(context).colorScheme.primaryContainer
          : colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: variant == AllineCardVariant.flat
          ? null
          : Border.all(color: colors.border),
      boxShadow: variant == AllineCardVariant.elevated && !isDark
          ? [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: .07),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );
  }
}
