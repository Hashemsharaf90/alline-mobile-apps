import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Alline Product Details Top App Bar.
///
/// RTL layout:
/// - Right (start): Back button
/// - Left (end): Favorite, Share, and Cart with reactive item count badge.
class AllineProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ProductDetailsModel? product;
  final bool isNotification;

  const AllineProductAppBar({
    super.key,
    required this.product,
    this.isNotification = false,
  });

  static const _primary = AllineColors.primary;
  static const _darkBlue = AllineColors.primaryDark;
  static const _border = Color(0xFFE1E8F2);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: 18,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                RouterHelper.getDashboardRoute(
                    action: RouteAction.pushNamedAndRemoveUntil);
              }
            },
          ),

          // Actions: Favorite, Share, Cart
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite button
              if (product?.id != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: _darkBlue.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: FavouriteButtonWidget(
                        backgroundColor: Colors.transparent,
                        productId: product?.id,
                        fromProductDetails: true,
                      ),
                    ),
                  ),
                ),

              // Share button
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Consumer<ProductDetailsController>(
                  builder: (context, details, _) {
                    return _CircleIconButton(
                      icon: Icons.share_outlined,
                      iconSize: 19,
                      onTap: () {
                        final link = details.sharableLink;
                        if (link != null && link.isNotEmpty) {
                          SharePlus.instance.share(ShareParams(text: link));
                        } else if (product?.slug != null) {
                          SharePlus.instance.share(
                              ShareParams(text: '${product?.name ?? "منتج"}\nhttps://alline.ye/product/${product?.slug}'));
                        }
                      },
                    );
                  },
                ),
              ),

              // Cart button with badge
              Consumer<CartController>(
                builder: (context, cart, _) {
                  final count = cart.cartList.length;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _CircleIconButton(
                        icon: Icons.shopping_cart_outlined,
                        iconSize: 20,
                        onTap: () => RouterHelper.getCartScreenRoute(
                            action: RouteAction.push),
                      ),
                      if (count > 0)
                        Positioned(
                          top: -2,
                          left: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    this.iconSize = 20,
    required this.onTap,
  });

  static const _darkBlue = AllineColors.primaryDark;
  static const _border = Color(0xFFE1E8F2);
  static const _text = Color(0xFF071B49);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _darkBlue.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: _text),
        ),
      ),
    );
  }
}
