import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class CustomMenuWidget extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String icon;
  final bool showCartCount;
  final VoidCallback onTap;
  const CustomMenuWidget(
      {super.key,
      required this.isSelected,
      required this.name,
      required this.icon,
      required this.onTap,
      this.showCartCount = false});

  @override
  Widget build(BuildContext context) {
    const icons = {
      'home': Icons.home_outlined,
      'all_category': Icons.grid_view_rounded,
      'cart': Icons.shopping_cart_outlined,
      'orders': Icons.receipt_long_outlined,
      'more': Icons.person_outline_rounded
    };
    const labels = {
      'home': 'الرئيسية',
      'all_category': 'التصنيفات',
      'cart': 'السلة',
      'orders': 'الطلبات',
      'more': 'حسابي'
    };
    final colors = AllineThemeColors.of(context);
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : colors.textSecondary;
    return Semantics(
        selected: isSelected,
        button: true,
        child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10)),
                      child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Icon(icons[name] ?? Icons.person_outline_rounded,
                                size: 23, color: color),
                            if (showCartCount)
                              PositionedDirectional(
                                  top: -3,
                                  end: 0,
                                  child: Consumer<CartController>(
                                      builder: (_, cart, __) {
                                    final count = cart.cartList.length;
                                    if (count == 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 1),
                                        constraints: const BoxConstraints(
                                            minWidth: 16, minHeight: 16),
                                        decoration: BoxDecoration(
                                            color: colors.accent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.5)),
                                        child: Text(
                                            count > 99
                                                ? '99+'
                                                : count.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: colors.textPrimary,
                                                fontWeight: FontWeight.w700)));
                                  })),
                          ]),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[name] ?? name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: color)),
                  ]),
            )));
  }
}
