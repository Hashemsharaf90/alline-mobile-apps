import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';

/// Search entry point for the supermarket. Uses the existing search flow.
class SmSearchBarWidget extends StatelessWidget {
  const SmSearchBarWidget({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: colors.surface,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      child: InkWell(
        onTap: () => _openSearch(context),
        borderRadius: BorderRadius.circular(AllineRadius.input),
        child: Container(
          height: AllineTouchTarget.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(AllineRadius.input),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ابحث عن منتجات أو سوبر ماركت',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
