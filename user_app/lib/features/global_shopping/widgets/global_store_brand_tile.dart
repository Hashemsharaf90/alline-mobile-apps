import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_logo_widget.dart';

/// Shared, data-driven store identity tile for the global-shopping screen and
/// its compact home-screen rail.
class GlobalStoreBrandTile extends StatelessWidget {
  const GlobalStoreBrandTile({
    super.key,
    required this.store,
    required this.onTap,
    this.isLtr = false,
    this.compact = false,
  });

  final GlobalShoppingStoreModel store;
  final VoidCallback? onTap;
  final bool isLtr;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = isLtr || store.nameAr.trim().isEmpty
        ? store.name
        : store.nameAr;
    final active = onTap != null;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 8 : 14),
          child: compact
              ? _compactContent(context, name, active)
              : _fullContent(context, name, active),
        ),
      ),
    );
  }

  Widget _fullContent(BuildContext context, String name, bool active) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: GlobalStoreLogoWidget(
              store: store,
              width: 94,
              height: 54,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          active ? (store.manualPricing ? 'طلب وتسعير يدوي' : 'متاح للطلب') : 'قريباً',
          maxLines: 1,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: active ? scheme.onSurfaceVariant : scheme.tertiary,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: active ? scheme.primary.withValues(alpha: .08) : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            active ? 'تسوّق عبر Alline' : 'غير متاح حالياً',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: active ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _compactContent(BuildContext context, String name, bool active) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        GlobalStoreLogoWidget(store: store, width: 34, height: 34),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      )),
              Text(active ? 'تسوّق عبر Alline' : 'قريباً',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: active ? scheme.primary : scheme.onSurfaceVariant,
                      )),
            ],
          ),
        ),
      ],
    );
  }
}
