import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/edit_profile_screen.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/bank_info_screen.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/driver_records_screen.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/html_view_screen.dart';
import 'package:sixvalley_delivery_boy/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_delivery_boy/features/review/screens/review_screen.dart';
import 'package:sixvalley_delivery_boy/features/emergency_contact/screens/emergency_contact_screen.dart';
import 'package:sixvalley_delivery_boy/features/help_and_support/screens/help_and_support_screen.dart';
import 'package:sixvalley_delivery_boy/features/setting/screens/setting_screen.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;
  @override
  void initState() {
    super.initState();
    Get.find<ProfileController>().getProfile(isUpdate: false);
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('log_out'.tr),
                content: Text('do_you_want_to_log_out_this_account'.tr),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('cancel'.tr)),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('log_out'.tr))
                ]));
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      final success = await Get.find<AuthController>().clearSharedData();
      if (success) Get.offAll(() => const LoginScreen());
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Widget _row(IconData icon, String title, VoidCallback onTap) => ListTile(
      leading: Icon(icon),
      title: Text(title.tr),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap);
  Widget _section(String title, List<Widget> children) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        Text(title.tr, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(child: Column(children: children))
      ]);
  void _legal(String slug) {
    final pages = Get.find<SplashController>().defaultBusinessPages;
    final matches = pages?.where((page) => page.slug == slug);
    Get.to(() => HtmlViewScreen(
        page: matches?.isNotEmpty == true ? matches!.first : null));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBarWidget(title: 'alline_nav_account'.tr),
      body: RefreshIndicator(
          onRefresh: () => Get.find<ProfileController>().getProfile(),
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child:
                          GetBuilder<ProfileController>(builder: (controller) {
                        final profile = controller.profileModel;
                        if (profile == null) {
                          return controller.profileLoadFailed
                              ? AllineErrorState(
                                  onRetry: () => controller.getProfile())
                              : const AllineSkeleton();
                        }
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(children: [
                                        ClipOval(
                                            child: CustomImageWidget(
                                                image: profile
                                                        .imageFullUrl?.path ??
                                                    '',
                                                width: 64,
                                                height: 64)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(
                                                  '${profile.fName ?? ''} ${profile.lName ?? ''}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                              Text((profile.approvalStatus ==
                                                          'active'
                                                      ? 'alline_account_active'
                                                      : 'alline_status_unavailable')
                                                  .tr),
                                              Text(
                                                  (profile.isOnline == 1
                                                          ? 'online_now'
                                                          : 'offline_now')
                                                      .tr,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall)
                                            ]))
                                      ]))),
                              _section('alline_personal_section', [
                                _row(
                                    Icons.person_outline,
                                    'edit_profile',
                                    () => Get.to(
                                        () => const ProfileEditScreen())),
                                _row(
                                    Icons.two_wheeler_outlined,
                                    'vehicle_step_label',
                                    () => Get.to(() =>
                                        const DriverRecordsScreen(
                                            vehicle: true))),
                                _row(
                                    Icons.folder_outlined,
                                    'docs_step_label',
                                    () => Get.to(() =>
                                        const DriverRecordsScreen(
                                            vehicle: false)))
                              ]),
                              _section('alline_financial_section', [
                                _row(
                                    Icons.account_balance_outlined,
                                    'bank_info',
                                    () => Get.to(() => const BankInfoScreen())),
                                _row(
                                    Icons.account_balance_wallet_outlined,
                                    'my_wallet',
                                    () => Get.to(() => const WalletScreen(
                                        fromNotification: false,
                                        fromProfile: true)))
                              ]),
                              _section('alline_support_section', [
                                _row(Icons.star_outline, 'my_reviews',
                                    () => Get.to(() => const ReviewScreen())),
                                _row(
                                    Icons.emergency_outlined,
                                    'emergency_contact',
                                    () => Get.to(
                                        () => const EmergencyContactScreen())),
                                _row(Icons.settings_outlined, 'setting',
                                    () => Get.to(() => const SettingScreen())),
                                _row(
                                    Icons.support_agent_outlined,
                                    'help_and_support',
                                    () => Get.to(
                                        () => const HelpAndSupportScreen()))
                              ]),
                              _section('alline_legal_section', [
                                _row(
                                    Icons.privacy_tip_outlined,
                                    'privacy_policy',
                                    () => _legal('privacy-policy')),
                                _row(
                                    Icons.description_outlined,
                                    'terms_and_condition',
                                    () => _legal('terms-and-conditions'))
                              ]),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                  onPressed: _loggingOut ? null : _logout,
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error),
                                  icon: const Icon(Icons.logout),
                                  label: Text(
                                      (_loggingOut ? 'loading' : 'log_out')
                                          .tr)),
                            ]);
                      }))))));
}
