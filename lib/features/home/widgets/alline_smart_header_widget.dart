import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/screens/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/widgets/top_up_wallet_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllineSmartHeaderWidget extends StatelessWidget {
  const AllineSmartHeaderWidget({super.key});

  void _openSupport() async {
    final url = Uri.parse("https://wa.me/967777000000?text=مرحباً%20خدمة%20عملاء%20Alline");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 10,
        left: 14,
        right: 14,
      ),
      child: Row(
        children: [
          // Left Action Icons: Support, Search, Notification
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircularButton(
                context: context,
                icon: Icons.headset_mic_rounded,
                tooltip: 'الدعم الفني',
                iconColor: const Color(0xFF10B981),
                onTap: _openSupport,
              ),
              const SizedBox(width: 8),
              _buildCircularButton(
                context: context,
                icon: Icons.search_rounded,
                tooltip: 'البحث',
                iconColor: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              Consumer<NotificationController>(
                builder: (context, notifCtrl, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildCircularButton(
                        context: context,
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'الإشعارات',
                        iconColor: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen()),
                          );
                        },
                      ),
                      if ((notifCtrl.notificationModel?.notification?.length ?? 0) > 0)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          const Spacer(),

          // Center Wallet Balance Pill Badge
          Consumer<ProfileController>(
            builder: (context, profileCtrl, _) {
              double balance = profileCtrl.userInfoModel?.walletBalance ?? 0.0;
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const TopUpWalletBottomSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${balance.toStringAsFixed(0)} ر.ي',
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFFFBBF24),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Right Location Selector & Logo
          Consumer<AddressController>(
            builder: (context, addressCtrl, _) {
              String locationText = 'صنعاء';
              if (addressCtrl.addressList != null && addressCtrl.addressList!.isNotEmpty) {
                locationText = addressCtrl.addressList![0].city ?? addressCtrl.addressList![0].address ?? 'صنعاء';
                if (locationText.length > 14) {
                  locationText = '${locationText.substring(0, 14)}...';
                }
              }

              return InkWell(
                onTap: () {
                  RouterHelper.getSavedAddressListRoute(action: RouteAction.push);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Alline',
                        style: textBold.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: Theme.of(context).hintColor,
                          ),
                          Text(
                            locationText,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
            width: 0.8,
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: iconColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
