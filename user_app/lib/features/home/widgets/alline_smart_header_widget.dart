import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/screens/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/widgets/top_up_wallet_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllineSmartHeaderWidget extends StatelessWidget {
  const AllineSmartHeaderWidget({super.key});

  void _openSupport() async {
    const phone = "+967777000000";
    final url = Uri.parse("https://wa.me/967777000000?text=مرحباً%20خدمة%20عملاء%20Alline");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 8,
        left: 12,
        right: 12,
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
                onTap: _openSupport,
              ),
              const SizedBox(width: 6),
              _buildCircularButton(
                context: context,
                icon: Icons.search_rounded,
                tooltip: 'البحث',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
              const SizedBox(width: 6),
              Consumer<NotificationController>(
                builder: (context, notifCtrl, _) {
                  return Stack(
                    children: [
                      _buildCircularButton(
                        context: context,
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'الإشعارات',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen()),
                          );
                        },
                      ),
                      if ((notifCtrl.notificationModel?.notification?.length ?? 0) > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
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
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF7931A),
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'لك ${balance.toStringAsFixed(0)} ر.ي',
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 10),

          // Right Location Selector & Logo
          Consumer<AddressController>(
            builder: (context, addressCtrl, _) {
              String locationText = 'صنعاء، اليمن';
              if (addressCtrl.addressList != null && addressCtrl.addressList!.isNotEmpty) {
                locationText = addressCtrl.addressList![0].city ?? addressCtrl.addressList![0].address ?? 'صنعاء';
                if (locationText.length > 16) {
                  locationText = '${locationText.substring(0, 16)}...';
                }
              }

              return InkWell(
                onTap: () {
                  RouterHelper.getSavedAddressListRoute(action: RouteAction.push);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Alline',
                              style: textBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'ون',
                              style: textBold.copyWith(
                                color: const Color(0xFFE8115B),
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: Colors.redAccent,
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
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
