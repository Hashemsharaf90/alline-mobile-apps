import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/category_asset_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final int length;
  const CategoryWidget({super.key, required this.category, required this.index, required this.length});

  @override
  Widget build(BuildContext context) {
    int homeLength = length >= 10 ? 10 : length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: Provider.of<LocalizationController>(context, listen: false).isLtr
            ? index == 0
                ? Dimensions.homePagePadding
                : Dimensions.paddingSizeTwelve
            : 0,
        right: index + 1 == homeLength
            ? Dimensions.paddingSizeSmall
            : Provider.of<LocalizationController>(context, listen: false).isLtr
                ? 0
                : Dimensions.homePagePadding,
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CategoryAssetHelper.buildCircularCategoryAvatar(
              category: category,
              size: 63,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Center(
            child: SizedBox(
              width: 72,
              child: Text(
                category.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
