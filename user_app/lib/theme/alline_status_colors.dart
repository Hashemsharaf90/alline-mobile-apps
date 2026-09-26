import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

@immutable
class AllineStatusStyle {
  final Color foreground;
  final Color background;
  final IconData icon;

  const AllineStatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });
}

abstract final class AllineStatusColors {
  /// Maps only statuses that are already used by the customer API.
  static AllineStatusStyle order(BuildContext context, String? rawStatus) {
    final colors = AllineThemeColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final status = rawStatus?.toLowerCase();
    Color foreground;
    IconData icon;

    switch (status) {
      case 'pending':
        foreground = colors.warning;
        icon = Icons.schedule_rounded;
        break;
      case 'confirmed':
        foreground = primary;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'processing':
        foreground = primary;
        icon = Icons.inventory_2_outlined;
        break;
      case 'out_for_delivery':
        foreground = Theme.of(context).colorScheme.tertiary;
        icon = Icons.local_shipping_outlined;
        break;
      case 'delivered':
        foreground = colors.success;
        icon = Icons.task_alt_rounded;
        break;
      case 'canceled':
      case 'failed':
      case 'fail_to_delivered':
        foreground = colors.error;
        icon = Icons.cancel_outlined;
        break;
      case 'returned':
        foreground = colors.warning;
        icon = Icons.keyboard_return_rounded;
        break;
      default:
        foreground = colors.textSecondary;
        icon = Icons.info_outline_rounded;
    }

    return AllineStatusStyle(
      foreground: foreground,
      background: foreground.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? .18 : .10,
      ),
      icon: icon,
    );
  }
}
