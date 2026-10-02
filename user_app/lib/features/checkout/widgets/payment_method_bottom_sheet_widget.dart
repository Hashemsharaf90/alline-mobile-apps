import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/domain/models/local_wallet_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';

class PaymentMethodBottomSheetWidget extends StatelessWidget {
  final bool onlyDigital;
  final double payableAmount;

  const PaymentMethodBottomSheetWidget({
    super.key,
    required this.onlyDigital,
    required this.payableAmount,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.read<SplashController>().configModel;
    final isLoggedIn = context.read<AuthController>().isLoggedIn();
    final isLtr = context.read<LocalizationController>().isLtr;

    return Consumer3<CheckoutController, ProfileController, WalletController>(
      builder: (context, checkout, profile, wallet, _) {
        final balance = profile.balance ?? 0;
        final walletIsEnough = balance >= payableAmount;
        final localWallets = _supportedLocalWallets(
          checkout.offlinePaymentModel?.offlineMethods,
          wallet.localWalletMethods,
        );
        final hasCod = (config?.cashOnDelivery ?? false) && !onlyDigital;
        final hasWallet = config?.walletStatus == 1 && isLoggedIn;

        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .82,
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E8F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment:
                      isLtr ? Alignment.centerLeft : Alignment.centerRight,
                  child: Text(
                    isLtr ? 'Choose payment method' : 'اختر طريقة الدفع',
                    style: textBold.copyWith(
                      fontSize: 19,
                      color: const Color(0xFF071B49),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment:
                      isLtr ? Alignment.centerLeft : Alignment.centerRight,
                  child: Text(
                    isLtr
                        ? 'Only methods currently enabled by Alline are shown.'
                        : 'تظهر فقط الطرق المتاحة حاليًا من Alline.',
                    style: textRegular.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF6D85AF),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (hasCod)
                          _PaymentOptionCard(
                            title: isLtr
                                ? 'Cash on delivery'
                                : 'الدفع عند الاستلام',
                            subtitle: isLtr
                                ? 'Pay when your order arrives'
                                : 'ادفع عند استلام طلبك',
                            icon: Icons.payments_outlined,
                            selected: checkout.isCODChecked,
                            onTap: () => checkout.setOfflineChecked('cod'),
                          ),
                        if (hasWallet) ...[
                          if (hasCod) const SizedBox(height: 10),
                          _PaymentOptionCard(
                            title: isLtr
                                ? 'Alline wallet balance'
                                : 'رصيد محفظة Alline',
                            subtitle: walletIsEnough
                                ? (isLtr
                                    ? 'Available: ${PriceConverter.convertPrice(context, balance)}'
                                    : 'الرصيد المتاح: ${PriceConverter.convertPrice(context, balance)}')
                                : (isLtr
                                    ? 'Insufficient balance — ${PriceConverter.convertPrice(context, balance)}'
                                    : 'الرصيد غير كافٍ — ${PriceConverter.convertPrice(context, balance)}'),
                            icon: Icons.account_balance_wallet_outlined,
                            selected: checkout.isWalletChecked,
                            enabled: walletIsEnough,
                            warning: !walletIsEnough,
                            onTap: () {
                              if (!walletIsEnough) {
                                showCustomSnackBarWidget(
                                  isLtr
                                      ? 'Wallet balance is insufficient to complete the order.'
                                      : 'رصيد المحفظة غير كافٍ لإتمام الطلب.',
                                  context,
                                  snackBarType: SnackBarType.warning,
                                );
                                return;
                              }
                              checkout.setOfflineChecked('wallet');
                            },
                          ),
                        ],
                        if (localWallets.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FBFF),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFDCE7F4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet_rounded,
                                        color: AllineColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      isLtr ? 'Local wallets' : 'المحافظ المحلية',
                                      style: textBold.copyWith(
                                        fontSize: 15,
                                        color: const Color(0xFF071B49),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isLtr
                                      ? 'Choose a local wallet to complete your payment.'
                                      : 'اختر محفظتك المحلية لإتمام الدفع بسهولة.',
                                  style: textRegular.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF6D85AF),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...localWallets.map(
                                  (entry) {
                                    final logoAsset = Images.getWalletLogo(entry.value.methodName);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _PaymentOptionCard(
                                        title: _cleanWalletName(entry.value.methodName ?? '', isLtr),
                                        subtitle: isLtr
                                            ? 'Local wallet payment'
                                            : 'الدفع عبر محفظة محلية',
                                        imageAsset: logoAsset,
                                        imageUrl: entry.value.methodName != null ? wallet.localWalletMethods.where((m) => m.name?.trim().toLowerCase() == entry.value.methodName?.trim().toLowerCase()).firstOrNull?.logoUrl : null,
                                        icon: logoAsset == null ? Icons.phone_android_rounded : null,
                                        selected: checkout.isOfflineChecked &&
                                            checkout.offlineMethodSelectedIndex ==
                                                entry.key,
                                        onTap: () {
                                          if (!checkout.isOfflineChecked) {
                                            checkout.setOfflineChecked('offline');
                                          }
                                          checkout.setOfflinePaymentMethodSelectedIndex(
                                            entry.key,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!hasCod && !hasWallet && localWallets.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F8FE),
                              border: Border.all(
                                color: const Color(0xFFE1E8F2),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isLtr
                                  ? 'No payment method is available right now.'
                                  : 'لا توجد طريقة دفع متاحة حاليًا.',
                              textAlign: TextAlign.center,
                              style: textRegular.copyWith(
                                color: const Color(0xFF6D85AF),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  buttonText: isLtr ? 'Confirm selection' : 'تأكيد الاختيار',
                  onTap: _hasSelection(checkout)
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasSelection(CheckoutController checkout) =>
      checkout.isCODChecked ||
      checkout.isWalletChecked ||
      checkout.isOfflineChecked;

  List<MapEntry<int, OfflineMethods>> _supportedLocalWallets(
    List<OfflineMethods>? methods,
    List<LocalWalletMethodModel> enabledMethods,
  ) {
    if (methods == null || methods.isEmpty) return const [];
    return methods.asMap().entries.where((entry) {
      if (entry.value.status != null && entry.value.status != 1) return false;
      final code = _walletCode(entry.value.methodName ?? '');
      return code != null;
    }).toList();
  }

  String _cleanWalletName(String rawName, bool isLtr) {
    final code = _walletCode(rawName);
    switch (code) {
      case 'jeeb':
        return isLtr ? 'Jeeb Wallet' : 'محفظة جيب';
      case 'jawali':
        return isLtr ? 'Jawali Wallet' : 'محفظة جوالي';
      case 'one_cash':
        return isLtr ? 'One Cash Wallet' : 'محفظة ون كاش';
      case 'cash':
        return isLtr ? 'Cash Wallet' : 'محفظة كاش';
      case 'floosak':
        return isLtr ? 'Floosak Wallet' : 'محفظة فلوسك';
      default:
        return rawName;
    }
  }

  String? _walletCode(String value) {
    final text = value.trim().toLowerCase().replaceAll('_', ' ');
    if (text.contains('جيب') || text.contains('jeeb')) return 'jeeb';
    if (text.contains('جوالي') ||
        text.contains('jawali') ||
        text.contains('jawwali')) {
      return 'jawali';
    }
    if (text.contains('ون كاش') ||
        text.contains('ونكاش') ||
        text.contains('one cash') ||
        text.contains('onecash')) {
      return 'one_cash';
    }
    if (text.contains('فلوسك') ||
        text.contains('floosak') ||
        text.contains('flousak')) {
      return 'floosak';
    }
    if ((text.contains('كاش') || text.contains('cash')) && !text.contains('استلام')) {
      return 'cash';
    }
    return null;
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imageAsset;
  final String? imageUrl;
  final bool selected;
  final bool enabled;
  final bool warning;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imageAsset,
    this.imageUrl,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imageAsset!,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomImageWidget(
          image: imageUrl!,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
      );
    } else {
      leadingWidget = Icon(
        icon ?? Icons.phone_android_rounded,
        size: 24,
        color: enabled ? AllineColors.primary : const Color(0xFF6D85AF),
      );
    }

    return Material(
      color: selected ? const Color(0xFFF4F8FE) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? AllineColors.primary : const Color(0xFFE1E8F2),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected
                      ? AllineColors.primary.withValues(alpha: .10)
                      : const Color(0xFFF4F8FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: leadingWidget,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: enabled
                            ? const Color(0xFF071B49)
                            : const Color(0xFF6D85AF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: textRegular.copyWith(
                        fontSize: 12,
                        color: warning
                            ? AllineColors.error
                            : const Color(0xFF6D85AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AllineColors.primary : Colors.white,
                  border: Border.all(
                    color: selected
                        ? AllineColors.primary
                        : const Color(0xFFE1E8F2),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
