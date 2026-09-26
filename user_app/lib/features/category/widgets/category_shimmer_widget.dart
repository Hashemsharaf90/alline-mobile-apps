import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CategoryShimmerWidget extends StatelessWidget {
  const CategoryShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.homePagePadding),
            child: SizedBox(
              height: 50,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Provider.of<ThemeController>(context).darkTheme
                        ? Theme.of(context).primaryColor.withValues(alpha: .05)
                        : Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 1,
                          blurRadius: 5)
                    ]),
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).cardColor,
                  highlightColor: Colors.grey[300]!,
                  enabled: true,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                            height: 70,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Provider.of<ThemeController>(context)
                                        .darkTheme
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: .05)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10))),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                Container(
                                    height: 5,
                                    color: Theme.of(context).cardColor)
                              ]),
                        ),
                      ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer skeleton matching the exact 2-column photography card layout
class CategoryGridShimmerWidget extends StatelessWidget {
  final int itemCount;
  const CategoryGridShimmerWidget({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.84,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE1E8F2),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08071B49),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE8EEF5),
              highlightColor: const Color(0xFFF7FAFD),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Card Image Placeholder
                  Container(
                    color: const Color(0xFFE8EEF5),
                  ),

                  // Bottom Text Scrim Skeleton
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFDCE5F0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8D5E5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8D5E5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
