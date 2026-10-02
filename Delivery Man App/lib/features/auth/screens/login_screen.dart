import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_text_field_widget.dart';
import 'package:sixvalley_delivery_boy/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_delivery_boy/common/controllers/localization_controller.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/html_view_screen.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/features/splash/domain/models/business_pages_model.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/forget_password_screen.dart';
import 'package:sixvalley_delivery_boy/features/auth/widgets/code_picker_widget.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_welcome_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_pending_approval_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_changes_requested_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_profile_step_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_rejected_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_suspended_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;
  String? _countryDialCode = '880';

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController!.text = Get.find<AuthController>().getUserEmail();
    _passwordController!.text = Get.find<AuthController>().getUserPassword();
    final savedCountryCode = Get.find<AuthController>().getUserCountryCode();
    final configCountryCode = Get.find<SplashController>().configModel?.countryCode;
    _countryDialCode = savedCountryCode?.isNotEmpty == true
        ? savedCountryCode
        : CountryCode.fromCountryCode(configCountryCode?.isNotEmpty == true ? configCountryCode! : 'YE').dialCode ?? '+967';
    Get.find<AuthController>().updateCountryDialCode(_countryDialCode ?? '+967', isUpdate: false);
  }


  @override
  void dispose() {
    _emailController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Theme.of(context).canvasColor,
      body: Padding( padding:  EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Form(key: _formKeyLogin,
          child: GetBuilder<AuthController>( builder: (authController){
            return ListView( physics: const BouncingScrollPhysics(), children: [
              SizedBox(height: Dimensions.topSpace),

              Padding(padding:  EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Image.asset(Images.logoWithName, height: 50, fit: BoxFit.scaleDown, matchTextDirection: true,),),

              Center(
                  child: Column( children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text('${'welcome_to'.tr} ${AppConstants.companyName}',
                          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge,
                              color:Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor)),
                      SizedBox(width: 40, child: Image.asset(Images.hand))
                    ])])),
              const SizedBox(height: Dimensions.iconSizeExtraLarge),

              Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Center(
                  child: Text('login'.tr, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge,
                      color:Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor)),
                ),
                SizedBox(height: Dimensions.paddingSizeMin),

                Center(child: Text('to_reach_your_customer_destination'.tr,style: rubikRegular.copyWith(color: Theme.of(context).hintColor)))],),
              SizedBox(height: Dimensions.paddingSizeOverLarge),

              Directionality(textDirection: TextDirection.ltr, child: Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color:Theme.of(context).colorScheme.outline),borderRadius:BorderRadius.circular(12)),
                child:Row(children:[SizedBox(width:120,child:CodePickerWidget(
                  dialogBackgroundColor:Theme.of(context).cardColor,
                  onChanged:(countryCode)=>Get.find<AuthController>().updateCountryDialCode(countryCode.dialCode!),
                  initialSelection:_countryDialCode,favorite:[_countryDialCode!],showDropDownButton:true,
                  padding:const EdgeInsets.all(4),showFlagMain:true,flagWidth:24,
                  textStyle:rubikRegular.copyWith(color:Theme.of(context).colorScheme.onSurface))),
                  Expanded(child:CustomTextFieldWidget(hintText:'phone'.tr,noPadding:true,nextFocus:_passwordFocus,
                    controller:_emailController,focusNode:_emailFocus,inputType:TextInputType.phone,inputAction:TextInputAction.next))])),
              ),

              SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).primaryColor.withValues(alpha:.5)),
                    borderRadius: BorderRadius.circular(Dimensions.topSpace),
                    color: Get.isDarkMode ? Theme.of(context).primaryColor.withValues(alpha:.02) : Theme.of(context).primaryColor.withValues(alpha:.02),
                  ),
                  child: Stack(children: [
                    Container(width: 77, height: 53, decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha:.125),
                        borderRadius:  Get.find<LocalizationController>().isLtr?
                        BorderRadius.only(topLeft: Radius.circular(Dimensions.topSpace),
                            bottomLeft: Radius.circular(Dimensions.topSpace)):
                        BorderRadius.only(topRight: Radius.circular(Dimensions.topSpace),
                            bottomRight: Radius.circular(Dimensions.topSpace)))),

                    Padding(padding: const EdgeInsets.only(top : 3.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Padding(padding: const EdgeInsets.only(bottom : 4.0, left: 4),
                              child: SizedBox(width: 59,height: 20, child: Image.asset(Images.lock))),
                          Expanded(child: Padding(
                            padding: EdgeInsets.only( left: Dimensions.paddingSizeLarge),
                            child: CustomTextFieldWidget(
                                hintText: 'password_hint'.tr,
                                isPassword: true,
                                isShowSuffixIcon: true,
                                focusNode: _passwordFocus,
                                noPadding: true,
                                controller: _passwordController,
                                inputAction: TextInputAction.done),
                          )),
                        ]))])),

              Padding(padding:  EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        onTap: () => authController.toggleRememberMe(),
                        ///for making tap transparent
                        highlightColor: Theme.of(context).primaryColor.withValues(alpha:0),
                        splashColor: Theme.of(context).primaryColor.withValues(alpha:0),
                        child: Padding(
                          padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
                          child: Row(children: [
                            SizedBox(height: 20, width: 20,
                                child: Checkbox(value: authController.isActiveRememberMe, activeColor: Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                                    onChanged: (bool? value) {
                                  authController.toggleRememberMe();
                                  },
                                ),
                            ),
                            SizedBox(width: Dimensions.paddingSizeMin),

                            Text('remember_me'.tr, style: rubikRegular)]),
                        ),
                      ),
                    ),

                    InkWell(
                        highlightColor: Theme.of(context).primaryColor.withValues(alpha:0),
                        splashColor: Theme.of(context).primaryColor.withValues(alpha:0),
                        onTap: ()=> Get.to(const ForgotPasswordScreen()),
                        child: Padding(
                          padding: EdgeInsets.only(right: Dimensions.paddingSizeMin, top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
                          child: Text('forget_password'.tr,
                              style: rubikRegular.copyWith(color: Colors.transparent,
                                shadows: [
                                  Shadow(
                                      color: Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor,
                                      offset: const Offset(0, -4)
                                  )],
                                decoration: TextDecoration.underline,
                                decorationColor: Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor,)),
                        ))])),

              Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [authController.loginErrorMessage.isNotEmpty ?
                  CircleAvatar(backgroundColor: Colors.red, radius: Dimensions.paddingSizeExtraSmall) :
                  const SizedBox.shrink(),
                    SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Text(authController.loginErrorMessage,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: Colors.red)))]),

              !authController.isLoading ? CustomButtonWidget(
                btnTxt: 'login'.tr,
                onTap: () async {
                  String countryCode =  Get.find<AuthController>().countryCode.replaceAll('+', '');
                  String phone = _emailController!.text.trim();
                  String password = _passwordController!.text.trim();
                  if (phone.isEmpty) {
                    showCustomSnackBarWidget('enter_phone_number'.tr);
                  }else if (password.isEmpty) {
                    showCustomSnackBarWidget('enter_password'.tr);
                  }else if (password.length < 8) {
                    showCustomSnackBarWidget('password_should_be'.tr);
                  }else {

                    await authController.login(countryCode, phone, password).then((status) async {

                      if (status.isSuccess) {
                        if (authController.isActiveRememberMe) {
                          authController.saveUserCredentials(Get.find<AuthController>().countryCode, phone, password);
                        } else {
                          authController.clearUserEmailAndPassword();
                        }

                        if (status.approvalStatus == 'pending_approval') {
                          Get.offAll(() => const DriverPendingApprovalScreen());
                        } else if (status.approvalStatus == 'changes_requested') {
                          Get.offAll(() => DriverChangesRequestedScreen(reviewNote: status.reviewNote));
                        } else if (status.approvalStatus == 'draft') {
                          Get.offAll(() => const DriverProfileStepScreen());
                        } else {
                          await Get.find<ProfileController>().getProfile();
                          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen(pageIndex: 0)));
                        }
                      } else {
                        if (status.approvalStatus == 'account_rejected') {
                          Get.to(() => DriverRejectedScreen(reviewNote: status.reviewNote));
                        } else if (status.approvalStatus == 'account_suspended') {
                          Get.to(() => DriverSuspendedScreen(reviewNote: status.reviewNote));
                        } else {
                          showCustomSnackBarWidget(status.message);
                        }
                      }
                    }
                    );
                  }
                },
              ) :
              Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).primaryColor))),

              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  onPressed: () => Get.to(() => const DriverWelcomeScreen()),
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: Text(
                    'new_to_alline_register_now'.tr,
                    style: rubikBold.copyWith(fontSize: 14, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),

              GetBuilder<SplashController>
                (builder: (splashController) {
                  return GestureDetector(onTap: ()=> Get.to(()=> HtmlViewScreen(
                    page: _getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages)
                  )),
                    child: Padding(padding: EdgeInsets.only(top: Dimensions.menuProfileImageSize),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('terms_and_conditions'.tr,
                          style: rubikRegular.copyWith(color: Colors.transparent,
                            shadows: [
                              Shadow(
                                  color: Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor,
                                  offset: const Offset(0, -4)
                              )],
                            decoration: TextDecoration.underline,
                            decorationColor: Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor,))])),
                  );
                }
              ),

            ]);
          },
          ),
        ),
      ),
    );
  }

  BusinessPageModel? _getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if(pagesList != null && pagesList.isNotEmpty){
      for (var page in pagesList) {
        if(page.slug == slug) {
          pageModel = page;
        }
      }
    }
    return pageModel;
  }

}
