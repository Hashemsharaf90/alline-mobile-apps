import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

/// A compact, data-driven preview of the products and sellers in checkout.
/// Store totals use the same unit-price-minus-discount calculation as the cart.
class CheckoutProductsSummary extends StatelessWidget {
  final List<CartModel> cartItems;

  const CheckoutProductsSummary({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final groups = _groupItems(cartItems);
    if (groups.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF032C75).withValues(alpha: .03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'منتجات الطلب',
              style: textBold.copyWith(
                  fontSize: 16, color: const Color(0xFF071B49)),
            ),
          ),
          for (final group in groups) _SellerProductGroup(group: group),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<_SellerGroup> _groupItems(List<CartModel> items) {
    final groups = <String, List<CartModel>>{};
    final labels = <String, String>{};

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final groupId = item.cartGroupId?.trim();
      final storeName = item.globalStoreName?.trim();
      final sellerName = item.seller?.trim();
      final key = groupId != null && groupId.isNotEmpty
          ? 'group:$groupId'
          : storeName != null && storeName.isNotEmpty
              ? 'global:$storeName'
              : item.sellerId != null && item.sellerId != 0
                  ? 'seller:${item.sellerId}'
                  : sellerName != null && sellerName.isNotEmpty
                      ? 'name:$sellerName'
                      : 'store:$index';
      groups.putIfAbsent(key, () => <CartModel>[]).add(item);
      labels[key] = storeName?.isNotEmpty == true
          ? storeName!
          : sellerName?.isNotEmpty == true
              ? sellerName!
              : item.sellerIs == 'admin'
                  ? 'Alline'
                  : 'متجر';
    }

    return groups.entries
        .map((entry) => _SellerGroup(
              name: labels[entry.key] ?? 'متجر',
              items: entry.value,
            ))
        .toList(growable: false);
  }
}

class _SellerGroup {
  final String name;
  final List<CartModel> items;

  const _SellerGroup({required this.name, required this.items});

  int get quantity => items.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  double get subtotal => items.fold(0, (sum, item) {
        final price = item.price ?? 0;
        final unitPrice =
            (price - (item.discount ?? 0)).clamp(0.0, price).toDouble();
        return sum + unitPrice * (item.quantity ?? 0);
      });
}

class _SellerProductGroup extends StatelessWidget {
  final _SellerGroup group;

  const _SellerProductGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              textBold.copyWith(fontSize: 14, color: const Color(0xFF071B49)),
        ),
        subtitle: Text(
          '${group.quantity} منتجات',
          style: textRegular.copyWith(
              fontSize: 12, color: const Color(0xFF6D85AF)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              PriceConverter.convertPrice(context, group.subtotal),
              style: textBold.copyWith(
                  fontSize: 13, color: const Color(0xFF015FC9)),
            ),
            const Icon(Icons.expand_more_rounded,
                color: Color(0xFF6D85AF), size: 20),
          ],
        ),
        children: [
          for (var index = 0; index < group.items.length; index++) ...[
            if (index > 0) const Divider(height: 16, color: Color(0xFFF0F4FA)),
            _CartProductRow(item: group.items[index]),
          ],
        ],
      ),
    );
  }
}

class _CartProductRow extends StatelessWidget {
  final CartModel item;

  const _CartProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final image =
        item.thumbnailFullUrl?.path ?? item.thumbnail ?? item.image ?? '';
    final quantity = item.quantity ?? 0;
    final price = item.price ?? 0;
    final unitPrice =
        (price - (item.discount ?? 0)).clamp(0.0, price).toDouble();
    final variant = [item.variant, item.color]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 56,
            height: 56,
            color: const Color(0xFFF4F8FE),
            child: image.isEmpty
                ? const Icon(Icons.image_outlined, color: Color(0xFF6D85AF))
                : CustomImageWidget(image: image, width: 56, height: 56),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name?.trim().isNotEmpty == true ? item.name! : 'منتج',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                    fontSize: 13, color: const Color(0xFF071B49)),
              ),
              if (variant.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(
                      fontSize: 11, color: const Color(0xFF6D85AF)),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                'الكمية: $quantity',
                style: textRegular.copyWith(
                    fontSize: 11, color: const Color(0xFF6D85AF)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (item.price != null)
          Text(
            PriceConverter.convertPrice(context, unitPrice * quantity),
            textAlign: TextAlign.end,
            style:
                textBold.copyWith(fontSize: 12, color: const Color(0xFF071B49)),
          ),
      ],
    );
  }
}
