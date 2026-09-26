import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';

/// Search entry point and common grocery shortcuts for the Supermarket Hub.
class SmSearchBarWidget extends StatelessWidget {
  const SmSearchBarWidget({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
      child: Column(
        children: [
          InkWell(
            onTap: () => _openSearch(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCE7F4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: AllineColors.primary, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ابحث عن منتج، علامة أو قسم',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                        color: Color(0xFF6D85AF),
                      ),
                    ),
                  ),
                  Icon(Icons.tune_rounded,
                      color: AllineColors.primary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Shortcut(
                icon: Icons.local_fire_department_rounded,
                label: 'عروض اليوم',
                onTap: () => _openSearch(context),
              ),
              const SizedBox(width: 8),
              _Shortcut(
                icon: Icons.shopping_basket_outlined,
                label: 'أساسيات',
                onTap: () => _openSearch(context),
              ),
              const SizedBox(width: 8),
              _Shortcut(
                icon: Icons.bolt_rounded,
                label: 'الأكثر طلبًا',
                onTap: () => _openSearch(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCE7F4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AllineColors.accent, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF071B49),
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
