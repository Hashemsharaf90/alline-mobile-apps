import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

/// Compact greeting displayed between the header and search bar.
/// Shows "مرحبًا، [FirstName] 👋" when logged in with a known name,
/// or "مرحبًا 👋" otherwise.
class AllineGreetingWidget extends StatelessWidget {
  const AllineGreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    return Consumer2<AuthController, ProfileController>(
      builder: (context, auth, profile, _) {
        final isLoggedIn = auth.isLoggedIn();
        final firstName = profile.userInfoModel?.fName?.trim();
        final showName =
            isLoggedIn && firstName != null && firstName.isNotEmpty;

        return Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 15,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: showName ? 'مرحبًا، ' : 'مرحبًا ',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showName)
                  TextSpan(
                    text: firstName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const TextSpan(
                  text: ' 👋',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
