import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';

/// Prominent tappable search bar for the Supermarket Hub.
/// Navigates to [SearchScreen] when tapped.
class SmSearchBarWidget extends StatelessWidget {
  const SmSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E8F2)),
              boxShadow: [
                BoxShadow(
                  color: AllineColors.primaryDark.withValues(alpha: .04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AllineColors.primary, size: 23),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ابحث في السوبر ماركت',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      color: Color(0xFF6D85AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}