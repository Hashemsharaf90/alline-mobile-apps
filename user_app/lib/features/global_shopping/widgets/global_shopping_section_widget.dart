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

  List<GlobalShoppingStoreModel> _orderedStores(List<GlobalShoppingStoreModel> stores) {
    // In RTL 2x2 grid:
    // Index 0: Alibaba (Top-Right)
    // Index 1: AliExpress (Top-Left)
    // Index 2: SHEIN (Bottom-Right)
    // Index 3: Amazon (Bottom-Left)
    final map = {for (var s in stores) s.name.toLowerCase(): s};
    final ordered = <GlobalShoppingStoreModel>[];

    void addStore(String key, String fallbackName, String fallbackUrl) {
      final found = map.entries.firstWhere(
        (e) => e.key.contains(key),
        orElse: () => MapEntry(
          key,
          GlobalShoppingStoreModel(
            id: key,
            name: fallbackName,
            nameAr: fallbackName,
            domain: '$key.com',
            url: fallbackUrl,
            description: '',
            descriptionAr: '',
            status: 'active',
            statusLabelAr: 'متاح للطلب',
            requestSupported: true,
            manualPricing: false,
            automaticImportSupported: true,
            popular: true,
          ),
        ),
      ).value;
      ordered.add(found);
    }

    addStore('alibaba', 'Alibaba', 'https://arabic.alibaba.com');
    addStore('aliexpress', 'AliExpress', 'https://ar.aliexpress.com');
    addStore('shein', 'SHEIN', 'https://ar.shein.com');
    addStore('amazon', 'Amazon', 'https://www.amazon.com');

    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final storesCtrl = Provider.of<GlobalShoppingController>(context);
    final colors = context.allineColors;
    final displayStores = _orderedStores(storesCtrl.supportedStores);

    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أطلب من المواقع العالمية',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اختر متجراً عالمياً واطلب منه عبر Alline',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        color: colors.textSecondary,
                      ),
                    ),
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

          // The 2x2 Glossy Branded Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.72,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final store = displayStores[index];
              return GlobalStoreBrandTile(
                store: store,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GlobalStoreWebViewScreen(
                      storeName: store.name,
                      initialUrl: store.url,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Add Link Banner
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
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: const BorderRadius.all(Radius.circular(13)),
                      ),
                      child: const Icon(
                        Icons.link_rounded,
                        color: AllineColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لديك رابط منتج؟',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الصق الرابط وسنساعدك في طلبه',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'طلب عبر الرابط',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AllineColors.primary,
                    ),
                  ),
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
