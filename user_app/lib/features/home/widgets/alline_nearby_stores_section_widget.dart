import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/all_shop_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/shop_screen.dart';

class AllineNearbyStoresSectionWidget extends StatelessWidget {
  const AllineNearbyStoresSectionWidget({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ShopController>(
        builder: (context, controller, _) {
          final stores = (controller.topSellerModel?.sellers ??
                  controller.allSellerModel?.sellers ??
                  [])
              .where((seller) => seller.shop != null)
              .take(6)
              .toList();
          if (stores.isEmpty) return const SizedBox.shrink();
          final colors = context.allineColors;
          final theme = Theme.of(context);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [
              AllineSectionHeader(
                title: 'متاجر مميزة',
                onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AllTopSellerScreen(title: 'جميع المتاجر'))),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height:
                    136 + (MediaQuery.textScalerOf(context).scale(12) - 12) * 3,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: stores.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final seller = stores[index];
                    final shop = seller.shop!;
                    final banner = shop.bannerFullUrl?.path;
                    final picture = banner?.isNotEmpty == true
                        ? banner!
                        : shop.imageFullUrl?.path ?? '';
                    final rating = seller.averageRating;
                    final storeName = _safeStoreName(shop.name);
                    return SizedBox(
                      width: 132,
                      child: Material(
                        color: colors.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colors.border)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TopSellerProductScreen(
                                      sellerId: seller.id,
                                      temporaryClose:
                                          shop.temporaryClose ?? false,
                                      vacationStatus:
                                          shop.vacationStatus ?? false,
                                      vacationEndDate: shop.vacationEndDate,
                                      vacationStartDate: shop.vacationStartDate,
                                      vacationDurationType:
                                          shop.vacationDurationType,
                                      name: storeName,
                                      banner: shop.bannerFullUrl?.path,
                                      image: shop.imageFullUrl?.path))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                    height: 66,
                                    child: picture.isEmpty
                                        ? DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  theme.colorScheme.primary
                                                      .withValues(alpha: .10),
                                                  colors.skeletonHighlight,
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/alline/login_logo_transparent.png',
                                                width: 42,
                                                height: 42,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          )
                                        : CustomImageWidget(
                                            image: picture, fit: BoxFit.cover)),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(storeName,
                                            textDirection: TextDirection.rtl,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    fontSize: 12,
                                                    height: 1.25,
                                                    fontWeight: FontWeight.w700,
                                                    color: colors.textPrimary)),
                                        const Spacer(),
                                        Row(children: [
                                          if (rating != null && rating > 0) ...[
                                            Icon(Icons.star_rounded,
                                                size: 16, color: colors.accent),
                                            const SizedBox(width: 4),
                                            Text(rating.toStringAsFixed(1),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                        color: colors
                                                            .textPrimary)),
                                          ] else
                                            Text('استكشف المتجر',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                        fontSize: 10,
                                                        color: colors
                                                            .textSecondary)),
                                          const Spacer(),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: theme.colorScheme.primary),
                                        ]),
                                      ]),
                                )),
                              ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          );
        },
      );

  static String _safeStoreName(String? value) {
    final normalized = value?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    if (normalized.isEmpty ||
        RegExp(r'^[?\uFFFD\s._-]+$').hasMatch(normalized)) {
      return 'متجر Alline';
    }
    return normalized;
  }
}
