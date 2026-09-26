import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';

class GlobalShoppingSectionWidget extends StatelessWidget {
  const GlobalShoppingSectionWidget({super.key});

  static const _stores = [
    _GlobalStore('SHEIN', 'https://www.shein.com/'),
    _GlobalStore('Amazon', 'https://www.amazon.com/'),
    _GlobalStore('AliExpress', 'https://www.aliexpress.com/'),
    _GlobalStore('Alibaba', 'https://www.alibaba.com/'),
  ];

  @override
  Widget build(BuildContext context) => Container(
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
                      Text('اطلب منتجاتك من أشهر المواقع المدعومة',
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _stores.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => _StorePill(
                  store: _stores[index],
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GlobalStoreWebViewScreen(
                      storeName: _stores[index].name,
                      initialUrl: _stores[index].url,
                    ),
                  )),
                ),
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

  static void _openGlobal(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GlobalShoppingScreen()),
      );
}

class _StorePill extends StatelessWidget {
  final _GlobalStore store;
  final VoidCallback onTap;

  const _StorePill({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 122,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE1E8F2)),
          ),
          child: Text(
            store.name,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF071B49),
            ),
          ),
        ),
      );
}

class _GlobalStore {
  final String name;
  final String url;
  const _GlobalStore(this.name, this.url);
}
