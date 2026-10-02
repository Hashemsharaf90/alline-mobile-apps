import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/online_offline_button_widget.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool isBack, isSwitch, isCenterTitle;
  final Function()? onTap;
  const CustomAppBarWidget(
      {super.key,
      this.title,
      this.isBack = false,
      this.onTap,
      this.isSwitch = false,
      this.isCenterTitle = true});
  @override
  Widget build(BuildContext context) => AppBar(
          centerTitle: isCenterTitle,
          leading: isBack
              ? IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onTap ?? () => Get.back(),
                  icon: const BackButtonIcon())
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(Images.logo)),
          title: Text((title ?? '').tr,
              style: Theme.of(context).textTheme.titleSmall),
          actions: [
            if (isSwitch) const OnlineOfflineButtonWidget(),
            if (!isBack)
              IconButton(
                  tooltip: 'notification'.tr,
                  onPressed: () => Get.to(
                      () => const NotificationScreen(fromNotification: false)),
                  icon: const Icon(Icons.notifications_outlined)),
            const SizedBox(width: 4)
          ]);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
