import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';

/// The 12 supermarket-specific display categories.
const _kCategories = [
  _SmCategory(emoji: '\u{1F95B}', label: '\u0627\u0644\u0623\u0644\u0628\u0627\u0646'),
  _SmCategory(emoji: '\u{1F964}', label: '\u0627\u0644\u0645\u0634\u0631\u0648\u0628\u0627\u062a'),
  _SmCategory(emoji: '\u{1F35A}', label: '\u0645\u0648\u0627\u062f \u063a\u0630\u0627\u0626\u064a\u0629'),
  _SmCategory(emoji: '\u{1F966}', label: '\u062e\u0636\u0627\u0631 \u0648\u0641\u0648\u0627\u0643\u0647'),
  _SmCategory(emoji: '\u{1F35E}', label: '\u0645\u062e\u0628\u0648\u0632\u0627\u062a'),
  _SmCategory(emoji: '\u{1F36B}', label: '\u062d\u0644\u0648\u064a\u0627\u062a'),
  _SmCategory(emoji: '\u{1F96B}', label: '\u0645\u0639\u0644\u0628\u0627\u062a'),
  _SmCategory(emoji: '\u{1F9CA}', label: '\u0645\u062c\u0645\u062f\u0627\u062a'),
  _SmCategory(emoji: '\u{1F9F4}', label: '\u0645\u0646\u0638\u0641\u0627\u062a'),
  _SmCategory(emoji: '\u{1F9FC}', label: '\u0639\u0646\u0627\u064a\u0629 \u0634\u062e\u0635\u064a\u0629'),
  _SmCategory(emoji: '\u{1F3E0}', label: '\u0645\u0646\u0632\u0644\u064a\u0629'),
  _SmCategory(emoji: '\u{1F476}', label: '\u0623\u0637\u0641\u0627\u0644'),
];

class _SmCategory {
  final String emoji;
  final String label;
  const _SmCategory({required this.emoji, required this.label});
}

/// Horizontal category strip for the Supermarket Hub.
///
/// Shows 12 supermarket-specific categories as compact icon+label cards.
/// Fires [onCategorySelected] with a display label when tapped (null = all).
class SmCategoriesWidget extends StatefulWidget {
  final void Function(String? label)? onCategorySelected;
  const SmCategoriesWidget({super.key, this.onCategorySelected});

  @override
  State<SmCategoriesWidget> createState() => _SmCategoriesWidgetState();
}

class _SmCategoriesWidgetState extends State<SmCategoriesWidget> {
  int _selected = -1; // -1 = none selected

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _softBlue = Color(0xFFF4F8FE);
  static const _border = Color(0xFFE1E8F2);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AllineSectionHeader(
            title: '\u0627\u0644\u062a\u0635\u0646\u064a\u0641\u0627\u062a',
            onViewAll: () {
              setState(() => _selected = -1);
              widget.onCategorySelected?.call(null);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cat = _kCategories[index];
                final isSelected = _selected == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = isSelected ? -1 : index;
                    });
                    widget.onCategorySelected?.call(
                      isSelected ? null : cat.label,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    decoration: BoxDecoration(
                      color: isSelected ? _primary : _softBlue,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? _primary : _border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : _text,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}