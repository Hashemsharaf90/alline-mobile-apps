import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/sign_up_widget.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  final String? referCode;
  const AuthScreen(
      {super.key,
      this.fromLogout = false,
      this.fromPage,
      this.onLoginSuccess,
      this.referCode});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _phoneRegistration = true;

  @override
  void initState() {
    super.initState();
    _phoneRegistration = widget.referCode == null;
  }

  bool scrolled = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.referCode != null) {
          RouterHelper.getDashboardRoute(
              action: RouteAction.pushNamedAndRemoveUntil);
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Consumer<AuthController>(builder: (context, _, __) {
          return Column(children: [
            Stack(children: [
              Container(
                  height: 150,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor)),
              Image.asset(Images.loginBg,
                  fit: BoxFit.cover,
                  height: 150,
                  opacity: const AlwaysStoppedAnimation(.15)),
              if (widget.referCode != null)
                Positioned(
                    top: Dimensions.paddingSizeButton,
                    left: Provider.of<LocalizationController>(context,
                                listen: false)
                            .isLtr
                        ? Dimensions.paddingSizeLarge
                        : null,
                    right: Provider.of<LocalizationController>(context,
                                listen: false)
                            .isLtr
                        ? null
                        : Dimensions.paddingSizeLarge,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          size: 20, color: Theme.of(context).cardColor),
                      onPressed: () {
                        if (widget.referCode != null) {
                          RouterHelper.getDashboardRoute(
                              action: RouteAction.pushNamedAndRemoveUntil);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    )),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .03),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.asset(Images.logoWithNameImageWhite,
                          width: 130, height: 80)
                    ]),
                    Text(getTranslated('sign_up', context)!,
                        style: titilliumRegular.copyWith(
                          color: Theme.of(context).highlightColor,
                          fontSize: Dimensions.fontSizeLarge,
                        )),
                  ],
                ),
              ),
            ]),
            AnimatedContainer(
              transform: Matrix4.translationValues(0, -12, 0),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusExtraLarge))),
              duration: const Duration(seconds: 2),
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.marginSizeLarge),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        height: 0,
                                        width: 25,
                                        margin: const EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.paddingSizeSmall),
                                            color:
                                                Theme.of(context).primaryColor))
                                  ]),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).disabledColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  _registrationModeButton(context, phone: true),
                  _registrationModeButton(context, phone: false),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Expanded(
              child: _phoneRegistration
                  ? SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Column(children: [
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraLarge),
                        Icon(Icons.phone_android_rounded,
                            size: 64, color: Theme.of(context).primaryColor),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Text(
                          getTranslated('enter_mobile_number', context) ?? '',
                          textAlign: TextAlign.center,
                          style: titleRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraLarge),
                        CustomButton(
                          buttonText: getTranslated('continue', context),
                          onTap: () => RouterHelper.getOtpLoginRoute(
                            fromLogout: widget.fromLogout,
                            toNavigateScreen: widget.fromPage,
                            onLoginSuccess: widget.onLoginSuccess,
                          ),
                        ),
                      ]),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall),
                      child: SignUpWidget(
                        fromLogout: widget.fromLogout,
                        fromPage: widget.fromPage,
                        onLoginSuccess: widget.onLoginSuccess,
                        referCode: widget.referCode,
                        emailOnly: true,
                      ),
                    ),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _registrationModeButton(BuildContext context, {required bool phone}) {
    final selected = _phoneRegistration == phone;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => setState(() => _phoneRegistration = phone),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(phone ? Icons.phone_android_rounded : Icons.email_outlined,
                size: 18,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(getTranslated(phone ? 'phone' : 'email', context) ?? '',
                style: titleRegular.copyWith(
                    color: selected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor)),
          ]),
        ),
      ),
    );
  }
}
