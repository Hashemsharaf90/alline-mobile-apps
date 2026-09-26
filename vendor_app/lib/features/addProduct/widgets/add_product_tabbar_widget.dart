import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AddProductTitleBar extends StatelessWidget {
  final TabController tabController;
  const AddProductTitleBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final List<Tab> productTabs = [
      Tab(
        text: getTranslated('general_info', context) ?? 'المعلومات الأساسية',
      ),
      Tab(
        text: getTranslated('variations_tab_title', context) ?? 'الخيارات والأسعار',
      ),
      Tab(
        text: getTranslated('images_and_publishing_tab', context) ?? 'الصور والنشر',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AllineColors.backgroundLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: AllineColors.borderLight),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: tabController,
        tabs: productTabs,
        labelColor: Colors.white,
        unselectedLabelColor: AllineColors.textLight,
        labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
        unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: AllineColors.primary,
          boxShadow: [
            BoxShadow(
              color: AllineColors.primary.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}