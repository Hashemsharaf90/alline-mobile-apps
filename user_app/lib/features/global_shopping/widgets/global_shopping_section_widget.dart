import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_brand_tile.dart';
import 'package:provider/provider.dart';

class GlobalShoppingSectionWidget extends StatefulWidget {
  const GlobalShoppingSectionWidget({super.key});

  @override
  State<GlobalShoppingSectionWidget> createState() =>
      _GlobalShoppingSectionWidgetState();
}

class _GlobalShoppingSectionWidgetState
    extends State<GlobalShoppingSectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<GlobalShoppingController>(context, listen: false)
            .fetchSupportedStores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storesCtrl = Provider.of<GlobalShoppingController>(context);
    final colors = context.allineColors;
    return Container(
        color: colors.background,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تسوق من المواقع العالمية',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          )),
                      SizedBox(height: 2),
                      Text('اختر متجراً عالمياً واطلب منه عبر Alline',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12.5,
                            color: colors.textSecondary,
                          )),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _openGlobal(context),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 68,
              child: storesCtrl.isStoresLoading &&
                      storesCtrl.supportedStores.isEmpty
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : storesCtrl.hasStoresError
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: storesCtrl.fetchSupportedStores,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('تعذر تحميل المتاجر — إعادة المحاولة'),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: storesCtrl.supportedStores.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final store = storesCtrl.supportedStores[index];
                            return _StorePill(
                              store: store,
                              onTap: !store.requestSupported || store.url.isEmpty
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              GlobalStoreWebViewScreen(
                                            storeName: store.name,
                                            initialUrl: store.url,
                                          ),
                                        ),
                                      ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openGlobal(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.all(Radius.circular(13)),
                        ),
                        child: Icon(Icons.link_rounded,
                            color: AllineColors.primary, size: 24),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('لديك رابط منتج؟',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              )),
                          SizedBox(height: 2),
                          Text('الصق الرابط وسنساعدك في طلبه',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 11.5,
                                color: colors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                    Text('طلب عبر الرابط',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AllineColors.primary,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  static void _openGlobal(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GlobalShoppingScreen()),
      );
}

class _StorePill extends StatelessWidget {
  final GlobalShoppingStoreModel store;
  final VoidCallback? onTap;

  const _StorePill({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 164,
        child: GlobalStoreBrandTile(
          store: store,
          onTap: onTap,
          compact: true,
        ),
      );

}
