import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/screens/category_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/screens/supermarket_home_screen.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AllineServicesGridWidget extends StatelessWidget {
  const AllineServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'كل التصنيفات',
        'icon': Icons.grid_view_rounded,
        'badge': '',
        'bg_color': const Color(0xFF1E293B),
        'icon_color': const Color(0xFFF43F5E),
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        },
      },
      {
        'title': 'المطاعم',
        'icon': Icons.lunch_dining_rounded,
        'badge': 'طازج',
        'bg_color': const Color(0xFF1E293B),
        'icon_color': const Color(0xFFF59E0B),
        'action': () {
          // Open restaurants
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        },
      },
      {
        'title': 'السوبر ماركت',
        'icon': Icons.shopping_basket_rounded,
        'badge': 'سريع ⚡',
        'bg_color': const Color(0xFF1E293B),
        'icon_color': const Color(0xFF10B981),
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupermarketHomeScreen()),
          );
        },
      },
      {
        'title': 'شي إن SHEIN',
        'icon': Icons.shopping_bag_rounded,
        'badge': 'عالمي ✈️',
        'bg_color': const Color(0xFF1E293B),
        'icon_color': const Color(0xFFEC4899),
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GlobalStoreWebViewScreen(
                storeName: 'SHEIN - شي إن',
                initialUrl: 'https://m.shein.com/ar',
              ),
            ),
          );
        },
      },
      {
        'title': 'استلم بنفسك',
        'icon': Icons.takeout_dining_rounded,
        'badge': 'توفير',
        'bg_color': const Color(0xFF1E293B),
        'icon_color': const Color(0xFF38BDF8),
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupermarketHomeScreen()),
          );
        },
      },
      {
        'title': 'شراء عالمي',
        'icon': Icons.language_rounded,
        'badge': 'أمازون/علي',
        'bg_color': const Color(0xFF1E293B),
        'icon_color': const Color(0xFF8B5CF6),
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GlobalShoppingScreen()),
          );
        },
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = services[index];
          return InkWell(
            onTap: s['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 82,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: s['bg_color'] as Color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (s['icon_color'] as Color).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    s['icon'] as IconData,
                    size: 28,
                    color: s['icon_color'] as Color,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    s['title'] as String,
                    style: textBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
