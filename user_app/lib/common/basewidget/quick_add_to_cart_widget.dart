import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:provider/provider.dart';

/// Compact quick add-to-cart widget for supermarket product cards.
///
/// Shows a single [+] button when not in cart, or [-] qty [+] when in cart.
/// Calls the cart API silently (no popups or bottom sheets).
class QuickAddToCartWidget extends StatelessWidget {
  final Product product;
  final double height;
  final double iconSize;

  const QuickAddToCartWidget({
    super.key,
    required this.product,
    this.height = 32,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final tapHeight =
        height < AllineTouchTarget.minimum ? AllineTouchTarget.minimum : height;
    return Consumer<CartController>(
      builder: (context, cartController, _) {
        final cartItem = _findInCart(cartController);
        final int quantity = cartItem?.quantity ?? 0;
        final bool isLoading =
            cartItem?.increment == true || cartItem?.decrement == true;

        if (quantity == 0) {
          return _AddButton(
            height: tapHeight,
            iconSize: iconSize,
            isLoading: cartController.addToCartLoading,
            onTap: () => _addToCart(context, cartController),
          );
        }

        return _QuantityStepper(
          height: tapHeight,
          iconSize: iconSize,
          quantity: quantity,
          isLoading: isLoading,
          onIncrement: () => _increment(context, cartController, cartItem!),
          onDecrement: () => _decrement(context, cartController, cartItem!),
        );
      },
    );
  }

  CartModel? _findInCart(CartController cartController) {
    for (final item in cartController.cartList) {
      if (item.productId == product.id) return item;
    }
    return null;
  }

  int _findCartIndex(CartController cartController, CartModel item) {
    return cartController.cartList.indexOf(item);
  }

  Future<void> _addToCart(
      BuildContext context, CartController cartController) async {
    final cart = CartModelBody(
      productId: product.id,
      quantity: 1,
    );
    await cartController.addToCartAPISilent(
      cart,
      context,
      product.choiceOptions ?? [],
      null,
    );
  }

  Future<void> _increment(BuildContext context, CartController cartController,
      CartModel cartItem) async {
    final int index = _findCartIndex(cartController, cartItem);
    if (index < 0) return;
    await cartController.updateCartProductQuantity(
      cartItem.id,
      (cartItem.quantity ?? 1) + 1,
      context,
      true,
      index,
    );
  }

  Future<void> _decrement(BuildContext context, CartController cartController,
      CartModel cartItem) async {
    final int index = _findCartIndex(cartController, cartItem);
    if (index < 0) return;

    final int newQty = (cartItem.quantity ?? 1) - 1;
    if (newQty <= 0) {
      await cartController.removeFromCart(index);
    } else {
      await cartController.updateCartProductQuantity(
        cartItem.id,
        newQty,
        context,
        false,
        index,
      );
    }
  }
}

/// The initial [+] button when product is not in cart.
class _AddButton extends StatelessWidget {
  final double height;
  final double iconSize;
  final bool isLoading;
  final VoidCallback onTap;

  const _AddButton({
    required this.height,
    required this.iconSize,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return SizedBox(
      height: height,
      width: height,
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AllineRadius.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(AllineRadius.control),
          onTap: isLoading ? null : onTap,
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onPrimary,
                  ),
                )
              : Icon(Icons.add, color: onPrimary, size: iconSize),
        ),
      ),
    );
  }
}

/// The [-] qty [+] stepper when product is in cart.
class _QuantityStepper extends StatelessWidget {
  final double height;
  final double iconSize;
  final int quantity;
  final bool isLoading;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.height,
    required this.iconSize,
    required this.quantity,
    required this.isLoading,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AllineRadius.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            context,
            icon: Icons.remove,
            onTap: isLoading ? null : onDecrement,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onPrimary,
                    ),
                  )
                : Text(
                    '$quantity',
                    style: TextStyle(
                      color: onPrimary,
                      fontSize: iconSize * 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          _stepperButton(
            context,
            icon: Icons.add,
            onTap: isLoading ? null : onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(BuildContext context,
      {required IconData icon, VoidCallback? onTap}) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return InkWell(
      borderRadius: BorderRadius.circular(AllineRadius.control),
      onTap: onTap,
      child: SizedBox(
        width: height,
        height: height,
        child: Icon(icon, color: onPrimary, size: iconSize),
      ),
    );
  }
}
