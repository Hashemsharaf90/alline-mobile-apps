import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);


  Future<bool> get isConnected async {
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }


  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(Provider.of<SplashController>(Get.context!, listen: false).firstTimeConnectionCheck) {
        Provider.of<SplashController>(Get.context!, listen: false).setFirstTimeConnectionCheck(false);
      }else {
        final bool isConnected =
            result.isNotEmpty && !result.contains(ConnectivityResult.none);
        final messenger = ScaffoldMessenger.of(Get.context!);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          elevation: 4,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: const Color(0xFF071B49),
          duration: Duration(seconds: isConnected ? 2 : 4),
          content: Row(
            children: [
              Icon(
                isConnected
                    ? Icons.wifi_rounded
                    : Icons.wifi_off_rounded,
                color: isConnected
                    ? AllineColors.success
                    : AllineColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isConnected
                      ? getTranslated('connected', Get.context!)!
                      : getTranslated('no_connection', Get.context!)!,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    });
  }
}
