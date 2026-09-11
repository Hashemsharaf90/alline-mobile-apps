import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/screens/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/screens/more_screen_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/widgets/top_up_wallet_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllineSmartHeaderWidget extends StatelessWidget {
  const AllineSmartHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          // Alline Logo & Brand Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF1455AC),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1455AC).withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alline',
                    style: titilliumBold.copyWith(
                      fontSize: 17,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF1455AC)),
                      const SizedBox(width: 2),
                      Text(
                        'صنعاء، اليمن',
                        style: textRegular.copyWith(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Interactive Wallet Balance Pill
          Consumer<ProfileController>(
            builder: (context, profile, _) {
              final balance = profile.userInfoModel?.walletBalance ?? 0.0;
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
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1455AC).withOpacity(0.18) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1455AC).withOpacity(0.35) : const Color(0xFFDBEAFE),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1455AC),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.account_balance_wallet_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 75),
                        child: Text(
                          PriceConverter.convertPrice(context, balance),
                          style: titilliumBold.copyWith(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F3A7A),
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.add_circle_outline_rounded, size: 13, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F3A7A)),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 6),

          // Theme Toggle Button (Light / Dark)
          Consumer<ThemeController>(
            builder: (context, themeCtrl, _) {
              return InkWell(
                onTap: () => themeCtrl.toggleTheme(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF1455AC),
                    size: 19,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 6),

          // Notifications Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
