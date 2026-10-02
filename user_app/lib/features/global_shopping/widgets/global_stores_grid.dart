import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_logo_widget.dart';

class GlobalStoresGrid extends StatelessWidget {
  final List<GlobalShoppingStoreModel> stores;
  final ValueChanged<GlobalShoppingStoreModel> onStoreTap;

  const GlobalStoresGrid({
    super.key,
    required this.stores,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    // Ensure we display the 4 official stores in the canonical order
    final orderedStores = _normalizeFourStores(stores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'متاجرك العالمية',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: navyColor,
              ),
            ),
            Text(
              '4 وجهات تسوق',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2x2 Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 148,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final store = orderedStores[index];
            return _StoreCard(
              store: store,
              onTap: () => onStoreTap(store),
            );
          },
        ),
      ],
    );
  }

  List<GlobalShoppingStoreModel> _normalizeFourStores(List<GlobalShoppingStoreModel> inputStores) {
    final map = {for (var s in inputStores) s.name.toLowerCase(): s};

    GlobalShoppingStoreModel resolve(String key, String name, String nameAr, String domain, String url, String desc) {
      for (final entry in map.entries) {
        if (entry.key.contains(key)) return entry.value;
      }
      return GlobalShoppingStoreModel(
        id: key,
        name: name,
        nameAr: nameAr,
        domain: domain,
        url: url,
        description: desc,
        descriptionAr: desc,
        status: 'active',
        statusLabelAr: 'متاح للطلب',
        requestSupported: true,
        manualPricing: false,
        automaticImportSupported: true,
        popular: true,
      );
    }

    // In RTL 2x2 grid:
    // Slot 0 (Top-Right): Alibaba
    // Slot 1 (Top-Left): Amazon
    // Slot 2 (Bottom-Right): AliExpress
    // Slot 3 (Bottom-Left): SHEIN
    return [
      resolve('alibaba', 'Alibaba', 'علي بابا', 'arabic.alibaba.com', 'https://arabic.alibaba.com', 'منتجات الجملة والمصانع'),
      resolve('amazon', 'Amazon', 'أمازون', 'amazon.com', 'https://www.amazon.com', 'ملايين المنتجات من جميع الفئات'),
      resolve('aliexpress', 'AliExpress', 'علي إكسبريس', 'ar.aliexpress.com', 'https://ar.aliexpress.com', 'منتجات متنوعة من جميع الفئات'),
      resolve('shein', 'SHEIN', 'شي إن', 'ar.shein.com', 'https://ar.shein.com', 'أزياء عصرية بأسعار مميزة'),
    ];
  }
}

class _StoreCard extends StatelessWidget {
  final GlobalShoppingStoreModel store;
  final VoidCallback onTap;

  const _StoreCard({
    required this.store,
    required this.onTap,
  });

  String _arabicSubtitle(String storeName) {
    final lower = storeName.toLowerCase();
    if (lower.contains('alibaba')) return 'منتجات الجملة والمصانع';
    if (lower.contains('amazon')) return 'ملايين المنتجات من جميع الفئات';
    if (lower.contains('aliexpress')) return 'منتجات متنوعة من جميع الفئات';
    if (lower.contains('shein')) return 'أزياء عصرية بأسعار مميزة';
    return store.descriptionAr.isNotEmpty ? store.descriptionAr : 'متجر عالمي معتمد';
  }

  String _arabicTitle(String storeName) {
    final lower = storeName.toLowerCase();
    if (lower.contains('alibaba')) return 'علي بابا';
    if (lower.contains('amazon')) return 'أمازون';
    if (lower.contains('aliexpress')) return 'علي إكسبريس';
    if (lower.contains('shein')) return 'شي إن';
    return store.nameAr.isNotEmpty ? store.nameAr : store.name;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Store Logo
            SizedBox(
              height: 38,
              child: Center(
                child: GlobalStoreLogoWidget(
                  store: store,
                  width: 132,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Store Name & Category Subtitle
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _arabicTitle(store.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: navyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _arabicSubtitle(store.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),

            // Browse Store Action Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 15,
                    color: primaryBlue,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'تصفّح المتجر',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
