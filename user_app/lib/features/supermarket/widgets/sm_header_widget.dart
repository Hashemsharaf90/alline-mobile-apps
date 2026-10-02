import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:provider/provider.dart';

/// Branded Supermarket header: logo, title, delivery location and cart.
class SmHeaderWidget extends StatelessWidget {
  const SmHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: colors.surface,
      padding: EdgeInsetsDirectional.only(
        start: AllineSpacing.md,
        end: AllineSpacing.md,
        top: MediaQuery.paddingOf(context).top + AllineSpacing.xs,
        bottom: AllineSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _IconButton(
                icon: Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                tooltip: 'رجوع',
                onTap: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  'السوبر ماركت',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Selector<CartController, int>(
                selector: (_, cart) => cart.cartList.length,
                builder: (context, count, _) => count > 0
                    ? const SizedBox(width: 48, height: 48)
                    : _IconButton(
                        icon: Icons.shopping_cart_outlined,
                        tooltip: 'السلة',
                        onTap: () => RouterHelper.getCartScreenRoute(
                          action: RouteAction.push,
                          showBackButton: true,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: AllineSpacing.xs),
          Consumer<LocationController>(
            builder: (context, location, _) {
              final label = location.deliveryLabel?.trim();
              final hasLocation = label?.isNotEmpty == true;
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LocationSetupScreen(),
                  ),
                ),
                borderRadius: BorderRadius.circular(AllineRadius.control),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AllineSpacing.sm,
                    vertical: AllineSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(AllineRadius.control),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'موقع التوصيل',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasLocation
                                  ? label!
                                  : 'حدد موقعك لعرض المتاجر القريبة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: hasLocation
                                        ? colors.textPrimary
                                        : primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasLocation ? 'تغيير' : 'تحديد',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: primary),
                      ),
                      Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AllineRadius.control),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AllineRadius.control),
              border: Border.all(color: colors.border),
            ),
            child: Icon(icon, color: colors.textPrimary, size: 21),
          ),
        ),
      ),
    );
  }
}
