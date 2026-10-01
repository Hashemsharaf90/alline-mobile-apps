import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/cart_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_price_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';

class AllineProductCard extends StatefulWidget {
  final Product product;
  final bool compact;
  final bool grocery;
  const AllineProductCard({
    super.key,
    required this.product,
    this.compact = false,
    this.grocery = false,
  });
  @override
  State<AllineProductCard> createState() => _AllineProductCardState();
}

class _AllineProductCardState extends State<AllineProductCard> {
  bool _loading = false;

  Future<void> _quickAdd() async {
    if (_loading) return;
    if (widget.product.slug?.isNotEmpty != true) {
      RouterHelper.getProductDetailsRoute(
          action: RouteAction.push,
          productId: widget.product.id,
          slug: widget.product.slug);
      return;
    }
    setState(() => _loading = true);
    try {
      final service = context
          .read<ProductDetailsController>()
          .productDetailsServiceInterface;
      final response = await service.get(widget.product.slug!);
      if (!mounted) return;
      if (response.response?.statusCode != 200) {
        throw StateError('Unable to load product');
      }
      final product = ProductDetailsModel.fromJson(response.response!.data);
      if (product.id == null) {
        throw StateError('Product identifier is missing');
      }
      final shop = product.seller?.shop;
      final closed = product.addedBy == 'admin'
          ? context
                  .read<SplashController>()
                  .configModel
                  ?.inhouseTemporaryClose
                  ?.status ??
              false
          : shop?.temporaryClose ?? false;
      final onVacation = ShopHelper.isVacationActive(context,
          startDate: shop?.vacationStartDate,
          endDate: shop?.vacationEndDate,
          vacationDurationType: shop?.vacationDurationType,
          vacationStatus: shop?.vacationStatus,
          isInHouseSeller: product.addedBy == 'admin');
      if (closed || onVacation) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('المتجر غير متاح للطلب حاليًا')));
        return;
      }

      final requiresSelection = (product.choiceOptions?.isNotEmpty ?? false) ||
          (product.colors?.isNotEmpty ?? false) ||
          (product.digitalVariation?.isNotEmpty ?? false);

      if (!requiresSelection) {
        final auth = context.read<AuthController>();
        final config = context.read<SplashController>().configModel;
        if (config?.guestCheckOut == 0 && !auth.isLoggedIn()) {
          RouterHelper.getLoginRoute(action: RouteAction.push);
          return;
        }

        final minimumQuantity = product.minimumOrderQty ?? 1;
        final stock = product.currentStock;
        if (product.productType == 'physical' &&
            stock != null &&
            stock < minimumQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هذا المنتج غير متوفر بالكمية المطلوبة'),
            ),
          );
          return;
        }

        final response =
            await context.read<CartController>().addToCartAPISilent(
                  CartModelBody(
                    productId: product.id,
                    variant: '',
                    color: '',
                    quantity: minimumQuantity,
                  ),
                  context,
                  const [],
                  const [],
                  showSnackbar: true,
                );
        final statusCode = response.response?.statusCode;
        if (statusCode != 200 && statusCode != 201 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر إضافة المنتج إلى السلة. حاول مرة أخرى.'),
            ),
          );
        }
        return;
      }

      await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CartBottomSheetWidget(product: product));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تحميل المنتج. حاول مرة أخرى.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final product = widget.product;
    if (widget.grocery) {
      return SupermarketProductCard(product: product, onAdd: _quickAdd);
    }
    if (widget.compact) {
      return _buildCompactCard(context, colors, product);
    }
    final discounted = (product.discount ?? 0) > 0;
    final percent = product.discountType == 'percent' ||
        product.discountType == 'percentage';
    final rating = double.tryParse(product.reviewsAvgRating ?? '') ??
        ((product.rating?.isNotEmpty ?? false)
            ? double.tryParse(product.rating!.first.average ?? '')
            : null);
    final soldOut =
        product.productType == 'physical' && product.currentStock == 0;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: product.id == null
            ? null
            : () => RouterHelper.getProductDetailsRoute(
                productId: product.id,
                slug: product.slug,
                action: RouteAction.push),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child:
                            product.thumbnailFullUrl?.path?.isNotEmpty == true
                                ? CustomImageWidget(
                                    image: product.thumbnailFullUrl!.path!,
                                    fit: BoxFit.contain)
                                : ColoredBox(
                                    color: colors.background,
                                    child: Icon(Icons.shopping_bag_outlined,
                                        color: colors.textSecondary,
                                        size: 40)))),
                if (discounted)
                  PositionedDirectional(
                      top: 4,
                      start: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: colors.accent,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                              percent
                                  ? 'خصم ${product.discount!.toStringAsFixed(0)}٪'
                                  : 'عرض',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary)))),
                PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: .92),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          product.wishList == 1
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: product.wishList == 1
                              ? AllineColors.error
                              : colors.textPrimary,
                        ),
                      ),
                    )),
              ]),
              const SizedBox(height: 12),
              Text(product.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              if (rating != null && rating > 0)
                Row(children: [
                  Icon(Icons.star_rounded, color: colors.accent, size: 16),
                  const SizedBox(width: 3),
                  Text(rating.toStringAsFixed(1),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colors.textSecondary))
                ]),
              const Spacer(),
              if (discounted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: AllinePriceWidget(
                    price: product.unitPrice ?? 0,
                    isOldPrice: true,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AllinePriceWidget(
                        price: product.unitPrice ?? 0,
                        discount: product.discount,
                        discountType: product.discountType,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton.filled(
                      tooltip: soldOut ? 'غير متوفر' : 'أضف إلى السلة',
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: AllineColors.interactionBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        disabledBackgroundColor:
                            colors.border.withValues(alpha: .75),
                        disabledForegroundColor: colors.textSecondary,
                      ),
                      onPressed: soldOut ||
                              _loading ||
                              product.slug?.isNotEmpty != true
                          ? null
                          : _quickAdd,
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_shopping_cart_rounded,
                              size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ])),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    AllineThemeColors colors,
    Product product,
  ) {
    final soldOut =
        product.productType == 'physical' && product.currentStock == 0;
    final discounted = (product.discount ?? 0) > 0;
    final percent = product.discountType == 'percent' ||
        product.discountType == 'percentage';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceColor =
        isDark ? AllineColors.darkBrightBlue : AllineColors.priceBlue;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: product.id == null
            ? null
            : () => RouterHelper.getProductDetailsRoute(
                  productId: product.id,
                  slug: product.slug,
                  action: RouteAction.push,
                ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 94,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            product.thumbnailFullUrl?.path?.isNotEmpty == true
                                ? CustomImageWidget(
                                    image: product.thumbnailFullUrl!.path!,
                                    fit: BoxFit.contain,
                                  )
                                : ColoredBox(
                                    color: colors.skeletonHighlight,
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: colors.textSecondary,
                                      size: 34,
                                    ),
                                  ),
                      ),
                    ),
                    if (discounted)
                      PositionedDirectional(
                        top: 2,
                        start: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            percent
                                ? '-${product.discount!.toStringAsFixed(0)}٪'
                                : 'عرض',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    PositionedDirectional(
                      top: 2,
                      end: 2,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          tooltip: product.wishList == 1
                              ? 'إزالة من المفضلة'
                              : 'أضف إلى المفضلة',
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                colors.surface.withValues(alpha: .94),
                            side: BorderSide(color: colors.border),
                          ),
                          onPressed: () => _toggleFavorite(product),
                          icon: Icon(
                            product.wishList == 1
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: product.wishList == 1
                                ? colors.error
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _safeProductName(product.name),
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 2),
              if (discounted)
                AllinePriceWidget(
                  price: product.unitPrice ?? 0,
                  isOldPrice: true,
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AllinePriceWidget(
                        price: product.unitPrice ?? 0,
                        discount: product.discount,
                        discountType: product.discountType,
                        color: priceColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton.filled(
                      tooltip: soldOut ? 'غير متوفر' : 'أضف إلى السلة',
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: AllineColors.interactionBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        disabledBackgroundColor:
                            colors.border.withValues(alpha: .75),
                        disabledForegroundColor: colors.textSecondary,
                      ),
                      onPressed: soldOut ||
                              _loading ||
                              product.slug?.isNotEmpty != true
                          ? null
                          : _quickAdd,
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_shopping_cart_rounded,
                              size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(Product product) {
    if (product.id == null) return;
    final auth = context.read<AuthController>();
    if (!auth.isLoggedIn()) {
      RouterHelper.getLoginRoute(action: RouteAction.push);
      return;
    }
    final wishlist = context.read<WishListController>();
    final isFavorite =
        wishlist.addedIntoWish.contains(product.id) || product.wishList == 1;
    setState(() => product.wishList = isFavorite ? 0 : 1);
    if (isFavorite) {
      if (!wishlist.addedIntoWish.contains(product.id)) {
        wishlist.addedIntoWish.add(product.id!);
      }
      wishlist.removeWishList(product.id);
    } else {
      wishlist.addWishList(product.id);
    }
  }

  static String _safeProductName(String? value) {
    final normalized = value?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    if (normalized.isEmpty ||
        RegExp(r'^[?\uFFFD\s._-]+$').hasMatch(normalized)) {
      return 'منتج';
    }
    return normalized;
  }
}

class AllineProductCardCompact extends StatelessWidget {
  final Product product;
  const AllineProductCardCompact({super.key, required this.product});

  @override
  Widget build(BuildContext context) =>
      AllineProductCard(product: product, compact: true);
}

class AllineProductCardSkeleton extends StatelessWidget {
  const AllineProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.allineColors.skeletonBase,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.allineColors.border),
        ),
      );
}
