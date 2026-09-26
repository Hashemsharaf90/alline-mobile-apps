import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';

const _kCategories = [
  _SmCategory(emoji: '\u{1F95B}', label: 'الألبان'),
  _SmCategory(emoji: '\u{1F964}', label: 'المشروبات'),
  _SmCategory(emoji: '\u{1F35A}', label: 'مواد غذائية'),
  _SmCategory(emoji: '\u{1F966}', label: 'خضار وفواكه'),
  _SmCategory(emoji: '\u{1F35E}', label: 'مخبوزات'),
  _SmCategory(emoji: '\u{1F9F4}', label: 'منظفات'),
  _SmCategory(emoji: '\u{1F9FC}', label: 'عناية شخصية'),
  _SmCategory(emoji: '\u{1F3E0}', label: 'منزلية'),
];

class _SmCategory {
  final String emoji;
  final String label;
  const _SmCategory({required this.emoji, required this.label});
}

/// Horizontal category rail for the Alline supermarket hub.
class SmCategoriesWidget extends StatefulWidget {
  final void Function(String? label)? onCategorySelected;

  const SmCategoriesWidget({super.key, this.onCategorySelected});

  @override
  State<SmCategoriesWidget> createState() => _SmCategoriesWidgetState();
}

class _SmCategoriesWidgetState extends State<SmCategoriesWidget> {
  int _selected = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 16, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AllineSectionHeader(
            title: 'التصنيفات',
            subtitle: 'تصفح أقسام السوبرماركت بسرعة',
            onViewAll: () {
              setState(() => _selected = -1);
              widget.onCategorySelected?.call(null);
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = _kCategories[index];
                final selected = _selected == index;
                return Semantics(
                  button: true,
                  label: category.label,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selected = selected ? -1 : index);
                      widget.onCategorySelected?.call(
                        selected ? null : category.label,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 82,
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? AllineColors.primary
                            : const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AllineColors.primary
                              : const Color(0xFFDCE7F4),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AllineColors.primary
                                      .withValues(alpha: .18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white.withValues(alpha: .16)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 31),
                            ),
                          ),
                          Text(
                            category.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF071B49),
                            ),
                          ),
                        ],
                      ),
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
