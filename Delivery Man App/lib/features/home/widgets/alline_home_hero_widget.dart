import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_typography.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';

class AllineHomeHeroWidget extends StatelessWidget {
  const AllineHomeHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        final profile = profileController.profileModel;
        final bool isOnline = profileController.profileModel?.isOnline == 1;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'alline_greeting'.tr,
                          style: AllineTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile != null ? '${profile.fName ?? ''} ${profile.lName ?? ''}' : 'loading'.tr,
                          style: AllineTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Online/Offline Toggle
                  GestureDetector(
                    onTap: profileController.isStatusChanging || profile == null ? null : () {
                      final newStatus = isOnline ? 0 : 1;
                      Get.find<ProfileController>().profileStatusChange(context, newStatus);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: isOnline ? AllineColors.success.withValues(alpha: 0.1) : AllineColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? AllineColors.success : AllineColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profileController.isStatusChanging ? 'loading'.tr : isOnline ? 'online_now'.tr : 'offline_now'.tr,
                            style: AllineTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              if (!isOnline && profile != null) ...[
                SizedBox(width:double.infinity,child:OutlinedButton(onPressed:profileController.isStatusChanging?null:()=>profileController.profileStatusChange(context,1),child:Text('alline_connect_now'.tr))),
                const SizedBox(height:12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.power_settings_new_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'you_are_offline_wont_receive_orders'.tr,
                          style: AllineTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}
