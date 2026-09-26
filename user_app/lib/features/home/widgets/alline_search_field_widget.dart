import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllineSearchFieldWidget extends StatelessWidget {
  const AllineSearchFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF17243B) : const Color(0xFFF4F5F7);

    return ColoredBox(
      color: isDark ? const Color(0xFF101A2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF015FC9),
                      size: 23,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ابحث عن منتج أو متجر...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          fontSize: 13.5,
                          color: const Color(0xFF6D85AF),
                        ),
                      ),
                    ),
                    Semantics(
                      label: 'فلترة البحث',
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.tune_rounded,
                          size: 21,
                          color: Color(0xFF015FC9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
