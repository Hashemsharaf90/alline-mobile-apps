import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class AllineEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AllineEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => _AllineStateLayout(
        icon: icon,
        iconColor: Theme.of(context).colorScheme.primary,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      );
}

class AllineErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final Future<void> Function()? onRetry;

  const AllineErrorState({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => _AllineStateLayout(
        icon: Icons.wifi_off_rounded,
        iconColor: AllineThemeColors.of(context).error,
        title: title,
        message: message,
        actionLabel: onRetry == null ? null : retryLabel,
        onAction: onRetry == null ? null : () => onRetry!(),
      );
}

class AllineLoading extends StatelessWidget {
  final String? label;
  final double size;

  const AllineLoading({super.key, this.label, this.size = 28});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
          if (label != null) ...[
            const SizedBox(height: AllineSpacing.sm),
            Text(label!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ]),
      );
}

class _AllineStateLayout extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _AllineStateLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AllineSpacing.xxl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: iconColor),
          ),
          const SizedBox(height: AllineSpacing.lg),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AllineSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.textSecondary),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AllineSpacing.xl),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ]),
      ),
    );
  }
}
