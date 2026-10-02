import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/screens/supermarket_store_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_skeleton_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_state_widget.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:provider/provider.dart';

/// "متاجر قريبة منك" section.
///
/// Reads [ProductController.nearbySupermarkets] and renders rich store cards
/// in a horizontal list. Handles:
///   - skeleton while loading
///   - location prompt when no location is set
///   - empty state when no stores found
///   - error state placeholder
class SmNearbyStoresWidget extends StatelessWidget {
  const SmNearbyStoresWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, ctrl, _) {
        final stores = ctrl.nearbySupermarkets.whereType<Map>().toList();
        final hasLocation =
            ctrl.supermarketLatitude?.trim().isNotEmpty == true &&
                ctrl.supermarketLongitude?.trim().isNotEmpty == true;

        return Container(
          color: context.allineColors.surface,
          padding: const EdgeInsets.only(top: 4, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AllineSectionHeader(
                title:
                    '\u0645\u062a\u0627\u062c\u0631 \u0642\u0631\u064a\u0628\u0629 \u0645\u0646\u0643',
                subtitle:
                    '\u0645\u062a\u0627\u062c\u0631 \u062a\u0648\u0635\u0644 \u0625\u0644\u0649 \u0645\u0648\u0642\u0639\u0643',
              ),
              const SizedBox(height: 14),

              // States
              if (!hasLocation)
                _LocationPrompt(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocationSetupScreen(),
                    ),
                  ),
                )
              else if (ctrl.nearbySupermarketLoading)
                const SmNearbyStoresSkeleton()
              else if (ctrl.nearbySupermarketHasError)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 260,
                    child: AllineErrorState(
                      title: 'تعذّر تحميل المتاجر القريبة',
                      message: 'تحقّق من اتصالك وحاول مرة أخرى.',
                      onRetry: () => ctrl.getNearbySupermarkets(
                        isUpdate: true,
                        latitude: ctrl.supermarketLatitude,
                        longitude: ctrl.supermarketLongitude,
                      ),
                    ),
                  ),
                )
              else if (stores.isEmpty)
                const _EmptyStores()
              else
                SizedBox(
                  height: 220 +
                      (MediaQuery.textScalerOf(context).scale(14) - 14) * 6,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return _StoreCard(
                        store: store,
                        onTap: () => _openStore(context, store),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openStore(BuildContext context, Map store) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupermarketStoreScreen(
        slug: _str(store, 'slug').isEmpty ? null : _str(store, 'slug'),
        sellerId: _int(store, 'seller_id'),
        name: _str(store, 'name'),
        banner: _str(store, 'banner'),
        image: _str(store, 'image'),
        address: _str(store, 'address'),
        distanceKm: _dbl(store, 'distance_km'),
        estimatedDeliveryMinutes: _int(store, 'estimated_delivery_minutes'),
      ),
    ));
  }

  static String _str(Map s, String k) => s[k]?.toString().trim() ?? '';
  static int _int(Map s, String k) =>
      s[k] is int ? s[k] as int : int.tryParse('${s[k]}') ?? 0;
  static double? _dbl(Map s, String k) =>
      s[k] is num ? (s[k] as num).toDouble() : double.tryParse('${s[k]}');
}

// ── Store Card ───────────────────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final Map store;
  final VoidCallback onTap;

  const _StoreCard({required this.store, required this.onTap});

  String _s(String k) => store[k]?.toString().trim() ?? '';
  double? _d(String k) => store[k] is num
      ? (store[k] as num).toDouble()
      : double.tryParse('${store[k]}');

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final primary = Theme.of(context).colorScheme.primary;
    final name = _s('name');
    final image = _s('image');
    final distance = _d('distance_km');
    final eta = store['estimated_delivery_minutes'];
    final etaInt = eta is int ? eta : int.tryParse('$eta') ?? 0;
    final rating = _d('rating');
    final isOpen = _asFlag(store['is_open']);
    final doesNotDeliver = _asUnavailable(store['delivers_to_location']);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AllineRadius.card),
      child: Container(
        width: 224,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AllineRadius.card),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: image.isNotEmpty
                        ? CustomImageWidget(image: image, fit: BoxFit.cover)
                        : Container(
                            color: colors.background,
                            child: Icon(Icons.storefront_outlined,
                                color: primary, size: 38),
                          ),
                  ),
                  if (store['is_open'] != null && !doesNotDeliver)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOpen ? colors.success : colors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOpen ? 'مفتوح الآن' : 'مغلق الآن',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 10,
                            color: AllineColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (doesNotDeliver)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.textPrimary.withValues(alpha: .65),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '\u0644\u0627 \u064a\u0648\u0635\u0644 \u0625\u0644\u0649 \u0645\u0648\u0642\u0639\u0643',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 9,
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty
                        ? '\u0633\u0648\u0628\u0631 \u0645\u0627\u0631\u0643\u062a'
                        : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (rating != null && rating > 0) ...[
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: colors.accent, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                  ],
                  Wrap(
                    spacing: 2,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (distance != null) ...[
                        Icon(Icons.location_on_outlined,
                            color: primary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${distance.toStringAsFixed(1)} \u0643\u0645',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (etaInt > 0) ...[
                        Icon(Icons.delivery_dining_outlined,
                            color: colors.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '$etaInt \u062f\u0642\u064a\u0642\u0629',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _asFlag(Object? value) {
    final normalized = value?.toString().toLowerCase();
    return value == true ||
        value == 1 ||
        normalized == 'true' ||
        normalized == '1';
  }

  bool _asUnavailable(Object? value) {
    final normalized = value?.toString().toLowerCase();
    return value == false ||
        value == 0 ||
        normalized == 'false' ||
        normalized == '0';
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LocationPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _LocationPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AllineRadius.control),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.allineColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.allineColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_searching_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u062d\u062f\u062f \u0645\u0648\u0642\u0639\u0643 \u0644\u0646\u0639\u0631\u0636 \u0627\u0644\u0645\u062a\u0627\u062c\u0631 \u0627\u0644\u0642\u0631\u064a\u0628\u0629',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.allineColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\u0627\u0636\u063a\u0637 \u0644\u062a\u062d\u062f\u064a\u062f \u0645\u0648\u0642\u0639 \u0627\u0644\u062a\u0648\u0635\u064a\u0644',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          color: context.allineColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 20),
              ],
            ),
          ),
        ),
      );
}

class _EmptyStores extends StatelessWidget {
  const _EmptyStores();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.store_mall_directory_outlined,
                color: context.allineColors.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(
              '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u062a\u0627\u062c\u0631 \u0633\u0648\u0628\u0631 \u0645\u0627\u0631\u0643\u062a \u0645\u062a\u0627\u062d\u0629 \u062d\u0627\u0644\u064a\u0627\u064b \u0641\u064a \u0645\u0646\u0637\u0642\u062a\u0643',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14,
                color: context.allineColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\u062c\u0631\u0651\u0628 \u062a\u063a\u064a\u064a\u0631 \u0645\u0648\u0642\u0639 \u0627\u0644\u062a\u0648\u0635\u064a\u0644 \u0623\u0648 \u0627\u0644\u0628\u062d\u062b \u0639\u0646 \u0645\u062a\u062c\u0631 \u0622\u062e\u0631.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12,
                color: context.allineColors.textSecondary,
              ),
            ),
          ],
        ),
      );
}
