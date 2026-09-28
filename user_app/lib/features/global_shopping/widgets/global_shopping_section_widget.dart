import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
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
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تسوق من المواقع العالمية',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF071B49),
                          )),
                      SizedBox(height: 2),
                      Text('اختر متجراً عالمياً واطلب منه عبر Alline',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12.5,
                            color: Color(0xFF6D85AF),
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
                  color: const Color(0xFFF4F8FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E8F2)),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                color: Color(0xFF071B49),
                              )),
                          SizedBox(height: 2),
                          Text('الصق الرابط وسنساعدك في طلبه',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 11.5,
                                color: Color(0xFF6D85AF),
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
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 152,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE1E8F2)),
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 34, height: 34, child: _logo()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF071B49),
                      ),
                    ),
                    if (!store.requestSupported)
                      const Text(
                        'قريباً',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 10,
                          color: Color(0xFF6D85AF),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _logo() {
    final logo = store.logoUrl;
    final uri = logo == null ? null : Uri.tryParse(logo);
    if (uri != null && uri.scheme == 'https') {
      if (uri.path.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          logo!,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => _storeMark(),
          errorBuilder: (_, __, ___) => _storeMark(),
        );
      }
      return Image.network(
        logo!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _storeMark(),
      );
    }
    return _storeMark();
  }

  Widget _storeMark() => Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        color: const Color(0xFFF4F8FE),
        child: Text(
          store.name.isEmpty ? '?' : store.name.substring(0, 1).toUpperCase(),
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF015FC9),
          ),
        ),
      );
}
