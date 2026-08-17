import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class GlobalShoppingSectionWidget extends StatelessWidget {
  const GlobalShoppingSectionWidget({super.key});

  static const List<_GlobalStore> _stores = [
    _GlobalStore(
      name: 'AliExpress',
      url: 'https://www.aliexpress.com/',
      color: Color(0xFFEE3B2F),
    ),
    _GlobalStore(
      name: 'Alibaba.com',
      url: 'https://www.alibaba.com/',
      color: Color(0xFFFF7A1A),
      badgeAr: 'جملة',
      badgeEn: 'Wholesale',
    ),
    _GlobalStore(
      name: 'Amazon',
      url: 'https://www.amazon.com/',
      color: Color(0xFFFFA41C),
      badgeAr: 'شائع',
      badgeEn: 'Popular',
    ),
    _GlobalStore(
      name: 'SHEIN',
      url: 'https://www.shein.com/',
      color: Color(0xFF111111),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.homePagePadding,
        Dimensions.paddingSizeSmall,
        Dimensions.homePagePadding,
        Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title with 'Paste Link' Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLtr ? 'Order from Global Stores' : 'اطلب من المتاجر العالمية',
                textAlign: TextAlign.start,
                style: textBold.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GlobalShoppingScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, color: Theme.of(context).primaryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isLtr ? 'Order with Link ⚡' : 'اطلب برابط ⚡',
                        style: textBold.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Direct Paste & Price Banner
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GlobalShoppingScreen()),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3C72).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.link, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLtr ? 'Have a product link? Paste & price it now!' : 'عندك رابط سلعة؟ الصقه واحسب سعره واصل فوراً!',
                          style: textBold.copyWith(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLtr ? 'Instant AI quotation with Yemen delivery' : 'تسعير فوري بالذكاء الاصطناعي مع التوصيل لليمن',
                          style: textRegular.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Stores Grid
          GridView.builder(
            itemCount: _stores.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              childAspectRatio: 2.05,
            ),
            itemBuilder: (context, index) => _GlobalStoreCard(
              store: _stores[index],
              isLtr: isLtr,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalStoreCard extends StatelessWidget {
  final _GlobalStore store;
  final bool isLtr;

  const _GlobalStoreCard({
    required this.store,
    required this.isLtr,
  });

  @override
  Widget build(BuildContext context) {
    final badge = isLtr ? store.badgeEn : store.badgeAr;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GlobalStoreWebViewScreen(
              storeName: store.name,
              initialUrl: store.url,
            ),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: store.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: store.color.withValues(alpha: .20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                start: -18,
                top: -24,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              PositionedDirectional(
                end: -42,
                bottom: -58,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (badge != null)
                PositionedDirectional(
                  start: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: .8),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: textBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      store.name,
                      textDirection: TextDirection.ltr,
                      style: textBold.copyWith(
                        color: Colors.white,
                        fontSize: store.name == 'SHEIN' ? 30 : 25,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlobalStore {
  final String name;
  final String url;
  final Color color;
  final String? badgeAr;
  final String? badgeEn;

  const _GlobalStore({
    required this.name,
    required this.url,
    required this.color,
    this.badgeAr,
    this.badgeEn,
  });
}
