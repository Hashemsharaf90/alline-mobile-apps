import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_delivery_boy/features/maintenance/maintenance_screen.dart';
import 'package:sixvalley_delivery_boy/features/notification/domain/models/notification_body.dart';
import 'package:sixvalley_delivery_boy/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/features/splash/domain/models/config_model.dart' hide Colors;
import 'package:sixvalley_delivery_boy/features/update/screen/update_screen.dart';
import 'package:sixvalley_delivery_boy/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_delivery_boy/helper/network_info.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_delivery_boy/features/onboard/screens/onboarding_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_pending_approval_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_changes_requested_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_profile_step_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_rejected_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_suspended_screen.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  bool _configFailed = false;

  @override
  void initState() {
    super.initState();

    if (!AppConstants.localQa) {
    FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
    FirebaseMessaging.instance.subscribeToTopic(AppConstants.maintenanceModeTopic);
    }
    _onConnectivityChanged = NetworkInfo.checkConnectivity(context);
    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
  }

  void _route() {
    if (mounted) setState(() => _configFailed = false);
    bool showIntro = Get.find<SplashController>().showIntro() ?? false;
    Get.find<SplashController>().getConfigData().then((isSuccess) async {
      if (!isSuccess) {
        if (mounted) setState(() => _configFailed = true);
        return;
      }
      String? approvalStatus = Get.find<SharedPreferences>().getString(AppConstants.driverApprovalStatus);
      if(Get.find<AuthController>().isLoggedIn() && (approvalStatus == null || approvalStatus == 'active')) {
        await Get.find<ProfileController>().getProfile();
      }
      if(isSuccess) {
        Get.find<SplashController>().getBusinessPagesList('default');
        final config = Get.find<SplashController>().configModel;

        String? minimumVersion = "0";
        DeliveryManAppVersionControl? appVersion = config?.deliveryManAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion = appVersion?.forAndroid.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos.version ?? '0';
        }

        Timer(const Duration(seconds: 1), () async {

          if(compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const UpdateScreen()));
          } else if( config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.deliverymanApp == 1) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
              builder: (_) => const MaintenanceScreen(),
              settings: const RouteSettings(name: 'MaintenanceScreen'),
            ));
          }else{

            if(widget.body != null) {
              String notificationType = widget.body?.type??"";
              switch(notificationType.toLowerCase()) {
                case 'chatting' : {
                  Get.offAll(DashboardScreen(pageIndex: 2, chatIndex: widget.body?.messageKey == 'message_from_customer' ? 1 : widget.body?.messageKey == 'message_from_seller' ? 0 : 3));
                }
                break;

                case 'theme' : {
                  Get.offAll(const NotificationScreen(fromNotification: true));
                }
                break;

                case 'order' : {
                  Get.offAll(OrderDetailsScreen(orderModel: OrderModel(id:  widget.body?.orderId), fromNotification: true));
                }
                break;

                case 'wallet' : {
                  if(widget.body?.type  == 'wallet' && widget.body?.messageKey  == 'cash_collect_by_seller_message'){
                    Get.offAll(() => WalletScreen(fromNotification: true, selectedIndex:  widget.body?.messageKey == 'cash_collect_by_seller_message' ? 3 : 0));
                  }else{
                    Get.offAll(() => WalletScreen(fromNotification: true, selectedIndex:  widget.body?.messageKey == 'cash_collect_by_admin_message' ? 3 : 0));
                  }
                }
                break;

                case 'wallet_withdraw' : {
                  Get.offAll(() => WalletScreen(fromNotification: true, selectedIndex:  widget.body?.messageKey == 'withdraw_request_status_message' ? 1 : 0));
                }
                break;
                default: {
                  Get.offAll(const NotificationScreen(fromNotification: true));
                } break;
              }

            } else {
              if (Get.find<AuthController>().isLoggedIn()) {
                String? approvalStatus = Get.find<SharedPreferences>().getString(AppConstants.driverApprovalStatus);
                if (approvalStatus == 'pending_approval') {
                  Get.offAll(() => const DriverPendingApprovalScreen());
                } else if (approvalStatus == 'changes_requested') {
                  Get.offAll(() => const DriverChangesRequestedScreen());
                } else if (approvalStatus == 'draft') {
                  Get.offAll(() => const DriverProfileStepScreen());
                } else if (approvalStatus == 'account_rejected' || approvalStatus == 'rejected') {
                  Get.offAll(() => const DriverRejectedScreen());
                } else if (approvalStatus == 'account_suspended' || approvalStatus == 'suspended') {
                  Get.offAll(() => const DriverSuspendedScreen());
                } else {
                  Get.find<AuthController>().updateToken();
                  await Get.find<ProfileController>().getProfile();
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen(pageIndex: 0)));
                }
              } else {
                if (showIntro) {
                  Get.offAll(const OnBoardingScreen());
                } else {
                  Get.offAll(const LoginScreen());
                }
              }
            }
          }





        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,

      body: Center(child: Padding(padding:  EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(Images.logo, width: Dimensions.splashLogoWidth),
           SizedBox(height: Dimensions.paddingSizeDefault),
          Wrap(alignment: WrapAlignment.center, children: [
              Text(AppConstants.appName,
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge), textAlign: TextAlign.center),
               SizedBox(width: Dimensions.fontSizeExtraSmall),
              Text('APP', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge,
                  color: Theme.of(context).primaryColor), textAlign: TextAlign.center)]),
          if (_configFailed) ...[
            const SizedBox(height: 24),
            Text('alline_load_failed'.tr, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _route, child: Text('alline_retry'.tr)),
          ] else const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
        ]))),
    );
  }


  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part = i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part = i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }
}
