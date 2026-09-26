import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_loader_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/custom_checkbox_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

class CartWidget extends StatelessWidget {
  final CartModel? cartModel;
  final int index;
  final bool fromCheckout;
  final Color highLightColor;
  final bool isValidate;

  const CartWidget({
    super.key,
    this.cartModel,
    required this.index,
    required this.fromCheckout,
    required this.highLightColor,
    required this.isValidate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final item = cartModel;
    if (item == null) return const SizedBox.shrink();
    final minimum = item.productInfo?.minimumOrderQty ?? 1;
    final stock = item.productInfo?.totalCurrentStock ?? item.maxQuantity ?? 0;
    final quantity = item.quantity ?? minimum;
    final outOfStock = item.productType == 'physical' &&
        (item.isProductAvailable == 0 || quantity > stock);
    final belowMinimum = quantity < minimum;
    final hasProblem = outOfStock || belowMinimum;
    final discounted = (item.discount ?? 0) > 0;

    return Consumer<CartController>(builder: (context, controller, _) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isValidate && (item.isChecked ?? false) && hasProblem
                  ? colors.error
                  : colors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: CustomCheckbox(
                      key: ValueKey('cart-selection-${item.id}'),
                      visualDensity: VisualDensity.compact,
                      fillColor: WidgetStateProperty.resolveWith((states) =>
                          states.contains(WidgetState.selected)
                              ? primary
                              : colors.surface),
                      side: WidgetStateBorderSide.resolveWith((states) =>
                          BorderSide(
                              width: 1.7,
                              color: (item.isChecked ?? false)
                                  ? primary
                                  : colors.textSecondary)),
                      checkColor: Colors.white,
                      value: item.isChecked ?? false,
                      onChanged: (_) async {
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const CustomLoaderWidget());
                        await controller.addRemoveCartSelectedItem(
                            [item.id!], !(item.isChecked ?? false));
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                _ProductImage(item: item, outOfStock: outOfStock),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => RouterHelper.getProductDetailsRoute(
                        action: RouteAction.push,
                        productId: item.productId,
                        slug: item.slug),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.shoppingSource == 'global' ||
                            item.globalShoppingRequestId != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color:
                                    AllineColors.accent.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(7)),
                            child: Text(
                                item.globalStoreName?.isNotEmpty == true
                                    ? 'تسوق عالمي • ${item.globalStoreName}'
                                    : 'التسوق العالمي',
                                style: const TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF9A5A00))),
                          ),
                          const SizedBox(height: 5),
                        ],
                        Text(item.name ?? 'منتج',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall),
                        if (item.variant?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(item.variant!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 3,
                          children: [
                            Text(
                              PriceConverter.convertPrice(context,
                                  (item.price ?? 0) - (item.discount ?? 0)),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: primary),
                            ),
                            if (discounted)
                              Text(
                                PriceConverter.convertPrice(
                                    context, item.price ?? 0),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colors.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              if (hasProblem) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    outOfStock
                        ? (stock > 0
                            ? 'الكمية المتاحة حاليًا: $stock'
                            : 'هذا المنتج غير متوفر حاليًا')
                        : 'الحد الأدنى للطلب: $minimum',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.error,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 8),
              Row(children: [
                TextButton.icon(
                  onPressed: item.decrement == true
                      ? null
                      : () => controller.removeFromCartAPI(item.id, index),
                  style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 4)),
                  icon: item.decrement == true
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.delete_outline_rounded, size: 19),
                  label: const Text('حذف',
                      style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                _QuantitySelector(
                    item: item,
                    index: index,
                    quantity: quantity,
                    minimum: minimum,
                    stock: stock),
              ]),
            ]),
          ),
        ),
      );
    });
  }
}

class _ProductImage extends StatelessWidget {
  final CartModel item;
  final bool outOfStock;
  const _ProductImage({required this.item, required this.outOfStock});

  @override
  Widget build(BuildContext context) => Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: CustomImageWidget(
              image: item.productInfo?.thumbnailFullUrl?.path ??
                  item.thumbnailFullUrl?.path ??
                  '',
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (outOfStock)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .48),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text('غير متوفر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
      ]);
}

class _QuantitySelector extends StatelessWidget {
  final CartModel item;
  final int index;
  final int quantity;
  final int minimum;
  final int stock;
  const _QuantitySelector({
    required this.item,
    required this.index,
    required this.quantity,
    required this.minimum,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final controller = context.read<CartController>();
    final canAdd = item.productType == 'digital' || quantity < stock;
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _quantityButton(
          icon: Icons.remove_rounded,
          loading: item.decrement == true,
          enabled: quantity > minimum,
          onTap: () => controller.updateCartProductQuantity(
              item.id, quantity - 1, context, false, index),
        ),
        SizedBox(
          width: 38,
          child: Text('$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium),
        ),
        _quantityButton(
          icon: Icons.add_rounded,
          loading: item.increment == true,
          enabled: canAdd,
          onTap: () {
            if (!canAdd) {
              showCustomSnackBarWidget('لا يمكن تجاوز الكمية المتاحة', context,
                  snackBarType: SnackBarType.warning);
              return;
            }
            controller.updateCartProductQuantity(
                item.id, quantity + 1, context, true, index);
          },
        ),
      ]),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool loading,
    required bool enabled,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: loading || !enabled ? null : onTap,
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon, size: 19),
          padding: EdgeInsets.zero,
        ),
      );
}
