import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

/// Compact quick add-to-cart widget for supermarket product cards.
///
/// Shows a single [+] button when not in cart, or [-] qty [+] when in cart.
/// Uses the existing product-card action for stock, store and option checks.
class QuickAddToCartWidget extends StatefulWidget {
  final Product product;
  final double height;
  final double iconSize;
  final Future<void> Function()? onAdd;

  const QuickAddToCartWidget({
    super.key,
    required this.product,
    this.height = 32,
    this.iconSize = 18,
    this.onAdd,
  });

  @override
  State<QuickAddToCartWidget> createState() => _QuickAddToCartWidgetState();
}

class _QuickAddToCartWidgetState extends State<QuickAddToCartWidget> {
  bool _busy = false;
  Product get product => widget.product;
  double get height => widget.height;
  double get iconSize => widget.iconSize;

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر تحديث السلة. تحقق من اتصالك وحاول مرة أخرى.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
            isLoading: _busy,
            onTap: cartController.addToCartLoading || product.id == null
                ? null
                : () => _perform(() => _addToCart(context, cartController)),
          );
        }

        return _QuantityStepper(
          height: tapHeight,
          iconSize: iconSize,
          quantity: quantity,
          isLoading: isLoading || _busy,
          canIncrement: product.productType != 'physical' ||
              product.currentStock == null ||
              quantity < product.currentStock!,
          onIncrement: () =>
              _perform(() => _increment(context, cartController, cartItem!)),
          onDecrement: () =>
              _perform(() => _decrement(context, cartController, cartItem!)),
        );
      },
    );
  }

  CartModel? _findInCart(CartController cartController) {
    // Options must be selected explicitly; never edit an arbitrary variant.
    if ((product.choiceOptions?.isNotEmpty ?? false) ||
        (product.colors?.isNotEmpty ?? false)) {
      return null;
    }
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
    if (widget.onAdd != null) {
      await widget.onAdd!();
      return;
    }
    // Never submit a product requiring choices with null selection indexes.
    if ((product.choiceOptions?.isNotEmpty ?? false) ||
        (product.colors?.isNotEmpty ?? false) ||
        product.productType != 'physical') {
      RouterHelper.getProductDetailsRoute(
          action: RouteAction.push, productId: product.id, slug: product.slug);
      return;
    }
    final minimum = product.minimumOrderQuantity ?? 1;
    if (product.currentStock != null && product.currentStock! < minimum) return;
    final cart = CartModelBody(
      productId: product.id,
      quantity: minimum < 1 ? 1 : minimum,
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
    final minimum = product.minimumOrderQuantity ?? 1;
    if (newQty < (minimum < 1 ? 1 : minimum)) {
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
  final VoidCallback? onTap;

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
      width: double.infinity,
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
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add, color: onPrimary, size: iconSize),
                  const SizedBox(width: 4),
                  Text('أضف',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: onPrimary)),
                ]),
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
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.height,
    required this.iconSize,
    required this.quantity,
    required this.isLoading,
    required this.canIncrement,
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
        mainAxisSize: MainAxisSize.max,
        children: [
          _stepperButton(
            context,
            icon: Icons.remove,
            onTap: isLoading ? null : onDecrement,
          ),
          Expanded(
              child: Container(
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
          )),
          _stepperButton(
            context,
            icon: Icons.add,
            onTap: isLoading || !canIncrement ? null : onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(BuildContext context,
      {required IconData icon, VoidCallback? onTap}) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Semantics(
        button: true,
        enabled: onTap != null,
        label: icon == Icons.add ? 'زيادة الكمية' : 'تقليل الكمية',
        child: InkWell(
          borderRadius: BorderRadius.circular(AllineRadius.control),
          onTap: onTap,
          child: SizedBox(
            width: height,
            height: height,
            child: Icon(icon,
                color: onTap == null
                    ? onPrimary.withValues(alpha: .45)
                    : onPrimary,
                size: iconSize),
          ),
        ));
  }
}
