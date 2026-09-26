import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:shimmer/shimmer.dart';

class ProductShimmerItemWidget extends StatelessWidget {
  const ProductShimmerItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: colors.surface),
      child: Shimmer.fromColors(
        baseColor: colors.skeletonBase,
        highlightColor: colors.skeletonHighlight,
        enabled: true,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: colors.skeletonBase,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
            ),
          ),

          // Product Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, color: colors.skeletonBase),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 20,
                                width: 50,
                                color: colors.skeletonBase),
                          ]),
                    ),
                    Container(
                        height: 10, width: 50, color: colors.skeletonBase),
                    const Icon(Icons.star,
                        color: AllineColors.accent, size: 15),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
