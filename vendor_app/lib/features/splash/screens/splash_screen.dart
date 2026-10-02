import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/maintenance/maintenance_screen.dart';
import 'package:sixvalley_vendor_app/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_model.dart';
import 'package:sixvalley_vendor_app/features/refund/screens/refund_details_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/features/update/screen/update_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/network_info.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/notification/models/notification_body.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/auth_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _fallbackTimer;
  Timer? _navigationTimer;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    Provider.of<AuthController>(Get.context!, listen: false).setUnAuthorize(false, update: false);
    initCall();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fallbackTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> initCall() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Safety timeout: if network/DNS hangs after 10s, release the screen to user
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });

    NetworkInfo.checkConnectivity(context);

    try {
      final isSuccess = await Provider.of<SplashController>(context, listen: false).initConfig();
      _fallbackTimer?.cancel();

      if (!mounted) return;

      if (isSuccess) {
        Provider.of<SplashController>(Get.context!, listen: false).getBusinessPagesList('default');
        Provider.of<SplashController>(Get.context!, listen: false).initShippingTypeList(Get.context!, '');

        _navigationTimer = Timer(const Duration(milliseconds: 800), () async {
          if (!mounted) return;
          _navigateForward();
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (_) {
      _fallbackTimer?.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _navigateForward() async {
    if (!mounted) return;
    final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;
    SellerAppVersionControl? appVersion = config?.sellerAppVersionControl;
    String? minimumVersion = '0';

    if (Platform.isAndroid) {
      minimumVersion = appVersion?.forAndroid?.version ?? '0';
    } else if (Platform.isIOS) {
      minimumVersion = appVersion?.forIos?.version ?? '0';
    }

    if (compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
      Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const UpdateScreen()));
      return;
    }

    if (config?.maintenanceModeData?.maintenanceStatus == 1 &&
        config?.maintenanceModeData?.selectedMaintenanceSystem?.vendorApp == 1) {
      Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
        builder: (_) => const MaintenanceScreen(),
        settings: const RouteSettings(name: 'MaintenanceScreen'),
      ));
      return;
    }

    if (widget.body != null) {
      String notificationType = widget.body?.type ?? "";
      switch (notificationType.toLowerCase()) {
        case 'chatting':
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => InboxScreen(
              fromNotification: true,
              initIndex: widget.body?.messageKey == 'message_from_delivery_man' ? 1 : 0,
            ),
          ));
          break;
        case 'order':
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(
              orderId: int.parse(widget.body!.orderId.toString()),
              fromNotification: true,
            ),
          ));
          break;
        case 'wallet':
        case 'wallet_withdraw':
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => const WalletScreen(fromNotification: true),
          ));
          break;
        case 'product_request_approved_message':
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => const ProductListMenuScreen(fromNotification: true),
          ));
          break;
        case 'refund':
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => RefundDetailsScreen(
              fromNotification: true,
              refundModel: RefundModel(id: widget.body!.refundId),
              orderDetailsId: widget.body!.orderDetailsId,
            ),
          ));
          break;
        default:
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => const NotificationScreen(),
          ));
          break;
      }
    } else {
      final authController = Provider.of<AuthController>(context, listen: false);
      if (authController.isLoggedIn()) {
        await authController.updateToken(context);
        if (!mounted) return;
        Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
      }
    }
  }

  void _proceedDirectly() {
    if (!mounted) return;
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.isLoggedIn()) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AllineColors.primaryDark, // #032C75
              Color(0xFF022055),
              Color(0xFF011438),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Decorative Glow Accents
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AllineColors.orange.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AllineColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),

            // Main Brand Core Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),

                  // Center Logo & Title Block
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Luxury Logo Card
                          Container(
                            width: 104,
                            height: 104,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: AllineColors.orange.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              Images.allineLogoClean,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                Images.whiteLogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Brand Name
                          const Text(
                            'ألين للتاجر',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Tagline Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AllineColors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'منصة التاجر الذكية لإدارة المبيعات',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD6E4FA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom State Handling (Loading OR Error Card)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: _hasError
                        ? _buildErrorCard(context)
                        : _buildLoadingIndicator(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3.2,
            valueColor: const AlwaysStoppedAnimation<Color>(AllineColors.orange),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'جارٍ تهيئة المتجر والبيانات...',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            color: Color(0xFFB5CDFA),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Alline Seller • v${AppConstants.appVersion}',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1B3D).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AllineColors.orange.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AllineColors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AllineColors.orange,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'تعذر الاتصال بخادم ألين',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'يرجى التأكد من اتصال الإنترنت أو تشغيل الـ VPN لتجاوز القيود الإقليمية.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: Color(0xFFC2D4F8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: initCall,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.orange,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _proceedDirectly,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'المتابعة للتطبيق',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

