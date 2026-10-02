import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';

class AllineOnboardingHeader extends StatelessWidget {
  final int currentStep; // 1 to 5
  final String title;
  final String subtitle;

  const AllineOnboardingHeader({
    super.key,
    required this.currentStep,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = AllineColors.primaryBlue;
    final Color activeBg = Get.theme.colorScheme.primaryContainer;
    final Color inactiveColor = Get.theme.colorScheme.outline;

    final List<String> stepLabels = [
      'profile_step_label'.tr,
      'docs_step_label'.tr,
      'vehicle_step_label'.tr,
      'location_step_label'.tr,
      'review_step_label'.tr,
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      color: Get.theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step progress indicator row
          Row(
            children: List.generate(5, (index) {
              int stepNum = index + 1;
              bool isCompleted = stepNum < currentStep;
              bool isActive = stepNum == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AllineColors.success
                                  : isActive
                                      ? primaryBlue
                                      : activeBg,
                              border: Border.all(
                                color: isActive ? primaryBlue : inactiveColor,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check,
                                      size: 18, color: Colors.white)
                                  : Text(
                                      '$stepNum',
                                      style: rubikBold.copyWith(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stepLabels[index],
                            style: rubikMedium.copyWith(
                              fontSize: 10,
                              color: isActive ? primaryBlue : Colors.black45,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (index < 4)
                      Container(
                        width: 14,
                        height: 2,
                        color: stepNum < currentStep
                            ? AllineColors.success
                            : inactiveColor,
                        margin: const EdgeInsets.only(bottom: 18),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Title & Subtitle
          Text(
            title,
            style: rubikBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Get.theme.colorScheme.outline),
        ],
      ),
    );
  }
}
