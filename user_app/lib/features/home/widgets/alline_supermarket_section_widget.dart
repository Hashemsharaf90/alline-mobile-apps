import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AllineSupermarketSectionWidget extends StatelessWidget {
  const AllineSupermarketSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Consumer<CategoryController>(
        builder: (context, categoryController, _) {
      final category =
          _findSupermarketCategory(categoryController.categoryList);

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.homePagePadding,
          0,
          Dimensions.homePagePadding,
          Dimensions.paddingSizeDefault,
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Text(
                isLtr ? 'Supermarket' : '?????? ?????',
                textAlign: TextAlign.start,
                style: textBold.copyWith(
                  fontSize: 22,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openSupermarket(context, category, isLtr),
              child: Text(isLtr ? 'View all' : '??? ????'),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openSupermarket(context, category, isLtr),
            child: Ink(
              height: 156,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: const DecorationImage(
                  image: AssetImage(Images.allineSupermarketBanner),
                  fit: BoxFit.cover,
                ),
                boxShadow: ThemeShadow.getShadow(context),
              ),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      Colors.white.withValues(alpha: .92),
                      Colors.white.withValues(alpha: .40),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLtr
                              ? 'Daily shopping, made easier'
                              : '???? ???? ????',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(
                            fontSize: 19,
                            color: const Color(0xFF0C2344),
                          ),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        Text(
                          isLtr
                              ? 'Food, home essentials, and fresh deals in one place.'
                              : '???? ??????? ???????? ??????? ????? ????? ?? ???? ????.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: const Color(0xFF446172),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }

  CategoryModel? _findSupermarketCategory(List<CategoryModel> categories) {
    const keywords = [
      '????',
      '?????',
      '????',
      '????',
      '?????',
      'supermarket',
      'grocery',
      'food',
      'shopping',
    ];

    for (final category in categories) {
      final name = (category.name ?? '').toLowerCase();
      final slug = (category.slug ?? '').toLowerCase();
      if (keywords
          .any((keyword) => name.contains(keyword) || slug.contains(keyword))) {
        return category;
      }
    }

    return null;
  }

  void _openSupermarket(
      BuildContext context, CategoryModel? category, bool isLtr) {
    if (category?.id == null) {
      showCustomSnackBarWidget(
        isLtr
            ? 'Supermarket category is not configured yet.'
            : '?? ??? ????? ??? ?????? ????? ???.',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: category!.id,
      name: category.name,
    );
  }
}
