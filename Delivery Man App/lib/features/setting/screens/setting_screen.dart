import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/theme_botton_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/features/language/screens/choose_language_screen.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBarWidget(title: 'setting'.tr, isBack: true),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('alline_appearance'.tr,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
            child: Column(children: [
          ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text('theme'.tr),
              trailing: const ThemeButtonWidget()),
          ListTile(
              leading: const Icon(Icons.language),
              title: Text('language'.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => const ChooseLanguageScreen()))
        ])),
        const SizedBox(height: 24),
        Text('alline_app_info'.tr,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        const Card(
            child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(AppConstants.appName),
                subtitle: Text(AppConstants.appVersion))),
      ]));
}
