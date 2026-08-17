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
        'subtitle': '+500 صنف',
        'icon': Icons.grid_view_rounded,
        'badge': 'الكل',
        'badge_color': const Color(0xFF64748B),
        'gradient': const [Color(0xFF1E293B), Color(0xFF0F172A)],
        'icon_gradient': const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        },
      },
      {
        'title': 'المطاعم',
        'subtitle': 'وجبات ساخنة',
        'icon': Icons.lunch_dining_rounded,
        'badge': 'طازج 🔥',
        'badge_color': const Color(0xFFF59E0B),
        'gradient': const [Color(0xFF78350F), Color(0xFF451A03)],
        'icon_gradient': const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        },
      },
      {
        'title': 'السوبر ماركت',
        'subtitle': 'توصيل فوري',
        'icon': Icons.shopping_basket_rounded,
        'badge': 'سريع ⚡',
        'badge_color': const Color(0xFF10B981),
        'gradient': const [Color(0xFF064E3B), Color(0xFF022C22)],
        'icon_gradient': const [Color(0xFF34D399), Color(0xFF059669)],
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupermarketHomeScreen()),
          );
        },
      },
      {
        'title': 'شي إن SHEIN',
        'subtitle': 'موضة وأزياء',
        'icon': Icons.shopping_bag_rounded,
        'badge': 'عالمي ✈️',
        'badge_color': const Color(0xFFEC4899),
        'gradient': const [Color(0xFF831843), Color(0xFF500724)],
        'icon_gradient': const [Color(0xFFF472B6), Color(0xFFDB2777)],
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
        'subtitle': 'وفر التوصيل',
        'icon': Icons.takeout_dining_rounded,
        'badge': 'توفير ⭐',
        'badge_color': const Color(0xFF0284C7),
        'gradient': const [Color(0xFF0C4A6E), Color(0xFF082F49)],
        'icon_gradient': const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupermarketHomeScreen()),
          );
        },
      },
      {
        'title': 'شراء عالمي',
        'subtitle': 'أمازون وعلي',
        'icon': Icons.language_rounded,
        'badge': 'طلب خاص 🌐',
        'badge_color': const Color(0xFF8B5CF6),
        'gradient': const [Color(0xFF4C1D95), Color(0xFF2E1065)],
        'icon_gradient': const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
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
      height: 106,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final s = services[index];
          final gradientColors = s['gradient'] as List<Color>;
          final iconColors = s['icon_gradient'] as List<Color>;

          return InkWell(
            onTap: s['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 88,
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: iconColors[0].withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Top Mini Badge
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: s['badge_color'] as Color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s['badge'] as String,
                        style: textBold.copyWith(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Main Content
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        // 3D-like Glowing Icon Container
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: iconColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: iconColors[0].withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            s['icon'] as IconData,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s['title'] as String,
                          style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s['subtitle'] as String,
                          style: textRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
