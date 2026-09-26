import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/screens/supermarket_home_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/screens/supermarket_store_screen.dart';
import 'package:provider/provider.dart';

class AllineSupermarketSectionWidget extends StatelessWidget {
  const AllineSupermarketSectionWidget({super.key});

  static const _primary = AllineColors.primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    return Consumer<ProductController>(
      builder: (context, products, _) {
        final stores =
            products.nearbySupermarkets.whereType<Map>().take(3).toList();
        final hasLocation =
            (products.supermarketLatitude?.trim().isNotEmpty ?? false);

        return Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'احتياجاتك اليومية',
                subtitle: 'تسوق من السوبر ماركت القريبة منك',
                onTap: () => _openHub(context),
              ),
              const SizedBox(height: 12),
              if (!hasLocation)
                _LocationPrompt(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LocationSetupScreen(),
                  )),
                )
              else if (products.nearbySupermarketLoading)
                const _StoreSkeleton()
              else if (stores.isEmpty)
                _ExploreCard(onTap: () => _openHub(context))
              else
                SizedBox(
                  height: 150 +
                      (MediaQuery.textScalerOf(context).scale(14) - 14) * 3,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => _StoreCard(
                      store: stores[index],
                      onTap: () => _openStore(context, stores[index]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openHub(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SupermarketHomeScreen()),
      );

  void _openStore(BuildContext context, Map store) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupermarketStoreScreen(
        slug: _string(store, 'slug').isEmpty ? null : _string(store, 'slug'),
        sellerId: _integer(store, 'seller_id'),
        name: _string(store, 'name'),
        banner: _string(store, 'banner'),
        image: _string(store, 'image'),
        address: _string(store, 'address'),
        distanceKm: _decimal(store, 'distance_km'),
        estimatedDeliveryMinutes: _integer(store, 'estimated_delivery_minutes'),
      ),
    ));
  }

  static String _string(Map store, String key) =>
      store[key]?.toString().trim() ?? '';
  static int _integer(Map store, String key) => store[key] is int
      ? store[key] as int
      : int.tryParse('${store[key]}') ?? 0;
  static double? _decimal(Map store, String key) => store[key] is num
      ? (store[key] as num).toDouble()
      : double.tryParse('${store[key]}');
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionHeader(
      {required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.allineColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12.5,
                      color: context.allineColors.textSecondary,
                    )),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('عرض الكل',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontWeight: FontWeight.w700,
                  color: AllineSupermarketSectionWidget._primary,
                )),
          ),
        ],
      );
}

class _LocationPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _LocationPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.allineColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.allineColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: AllineSupermarketSectionWidget._primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text('حدد موقعك لعرض المتاجر القريبة',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    color: context.allineColors.textPrimary,
                  )),
            ),
            TextButton(onPressed: onTap, child: const Text('تحديد الموقع')),
          ],
        ),
      );
}

class _ExploreCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ExploreCard({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.allineColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.allineColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.storefront_outlined,
                  color: AllineSupermarketSectionWidget._primary, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text('استكشف السوبر ماركت والمنتجات المتاحة',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontWeight: FontWeight.w700,
                      color: context.allineColors.textPrimary,
                    )),
              ),
              Icon(Icons.arrow_back_rounded,
                  color: AllineSupermarketSectionWidget._primary),
            ],
          ),
        ),
      );
}

class _StoreCard extends StatelessWidget {
  final Map store;
  final VoidCallback onTap;
  const _StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = AllineSupermarketSectionWidget._string(store, 'name');
    final distance =
        AllineSupermarketSectionWidget._decimal(store, 'distance_km');
    final eta = AllineSupermarketSectionWidget._integer(
        store, 'estimated_delivery_minutes');
    final image = AllineSupermarketSectionWidget._string(store, 'image');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.allineColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.allineColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.allineColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: image.isNotEmpty
                      ? CustomImageWidget(image: image, fit: BoxFit.cover)
                      : const Icon(Icons.storefront_outlined,
                          color: AllineSupermarketSectionWidget._primary),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(name.isEmpty ? 'سوبر ماركت' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.allineColors.textPrimary,
                )),
            const SizedBox(height: 5),
            Text(
              [
                if (distance != null) '${distance.toStringAsFixed(1)} كم',
                if (eta > 0) '$eta دقيقة',
              ].join(' • '),
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 11.5,
                color: context.allineColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreSkeleton extends StatelessWidget {
  const _StoreSkeleton();

  @override
  Widget build(BuildContext context) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: context.allineColors.skeletonBase,
          borderRadius: BorderRadius.circular(16),
        ),
      );
}
