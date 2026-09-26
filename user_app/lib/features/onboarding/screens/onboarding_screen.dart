import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/setting/widgets/select_language_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import '../widgets/alline_welcome_view.dart';

class OnBoardingScreen extends StatelessWidget {
  // Retained for existing route callers.
  final Color indicatorColor;
  final Color selectedIndicatorColor;
  const OnBoardingScreen(
      {super.key,
      this.indicatorColor = Colors.grey,
      this.selectedIndicatorColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LocalizationController>().locale.languageCode == 'ar';
    return AllineWelcomeView(
      isArabic: isArabic,
      onRegister: () {
        RouterHelper.getAuthScreenRoute();
      },
      onLogin: () => RouterHelper.getLoginRoute(),
      onGuest: () {
        context.read<SplashController>().disableIntro();
        context.read<AuthController>().getGuestIdUrl();
        RouterHelper.getDashboardRoute(
            action: RouteAction.pushNamedAndRemoveUntil);
      },
      onLanguage: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SelectLanguageBottomSheetWidget(),
      ),
    );
  }
}
