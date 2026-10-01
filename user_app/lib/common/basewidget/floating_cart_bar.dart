import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:provider/provider.dart';

/// A sleek, persistent floating cart summary bar for Q-Commerce / Supermarket screens.
/// Automatically reveals itself when there are items in the cart, showing total item count,
/// total amount, and a direct checkout / view-cart button.
class FloatingCartBar extends StatelessWidget {
  final EdgeInsets? margin;

  const FloatingCartBar({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Consumer<CartController>(
      builder: (context, cartController, _) {
        final cartList = cartController.cartList;
        if (cartList.isEmpty) return const SizedBox();

        int totalCount = 0;
        double totalPrice = 0.0;

        for (final item in cartList) {
          final int qty = item.quantity ?? 1;
          totalCount += qty;
          final double price = item.discountedPrice ?? item.price ?? 0.0;
          totalPrice += (price * qty);
        }

        return SafeArea(
          child: Padding(
            padding: margin ??
                const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AllineRadius.button),
              onTap: () {
                RouterHelper.getCartScreenRoute(
                  action: RouteAction.push,
                  showBackButton: true,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AllineRadius.button),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Count is written beside the icon, avoiding an overlapping badge.
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 26,
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Items count & Total amount
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalCount ${isLtr ? (totalCount == 1 ? "item" : "items") : "منتجات"}',
                            style: textRegular.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.9),
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                          Text(
                            PriceConverter.convertPrice(context, totalPrice),
                            style: textBold.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "View Cart" action
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLtr ? 'View Cart' : 'عرض السلة',
                          style: textBold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isLtr
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
