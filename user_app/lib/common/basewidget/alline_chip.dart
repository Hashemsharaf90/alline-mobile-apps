import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class AllineChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final IconData? icon;

  const AllineChip({
    super.key,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AllineRadius.control),
        child: AnimatedContainer(
          duration: AllineDurations.fast,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: .11) : colors.surface,
            borderRadius: BorderRadius.circular(AllineRadius.control),
            border: Border.all(color: selected ? primary : colors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 18, color: selected ? primary : colors.textSecondary),
              const SizedBox(width: AllineSpacing.xs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: enabled
                        ? (selected ? primary : colors.textPrimary)
                        : colors.textSecondary.withValues(alpha: .55),
                  ),
            ),
          ]),
        ),
      ),
    );
  }
}
