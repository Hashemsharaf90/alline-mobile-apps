import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
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
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

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
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
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
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.85),
                    ],
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cart Icon with item badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$totalCount',
                              style: textBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                          Text(
                            PriceConverter.convertPrice(context, totalPrice),
                            style: textBold.copyWith(
                              color: Colors.white,
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
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isLtr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                          color: Colors.white,
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
