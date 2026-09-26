import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class ChoosePaymentWidget extends StatelessWidget {
  final bool onlyDigital;
  final double payableAmount;

  const ChoosePaymentWidget({
    super.key,
    required this.onlyDigital,
    required this.payableAmount,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.read<SplashController>().configModel;
    final isLoggedIn = context.read<AuthController>().isLoggedIn();
    final isLtr = context.read<LocalizationController>().isLtr;

    return Consumer2<CheckoutController, ProfileController>(
      builder: (context, checkout, profile, _) {
        final balance = profile.balance ?? 0;
        final walletIsEnough = balance >= payableAmount;
        final hasCod = (config?.cashOnDelivery ?? false) && !onlyDigital;
        final hasWallet = config?.walletStatus == 1 && isLoggedIn;
        final localWallets = _supportedLocalWallets(
          checkout.offlinePaymentModel?.offlineMethods,
        );

        final selectedWalletName = _selectedLocalWalletName(checkout, isLtr);
        final selectedWalletLogo = _selectedLocalWalletLogo(checkout);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E8F2)),
            boxShadow: [
              BoxShadow(
                color: AllineColors.primaryDark.withValues(alpha: .03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLtr ? 'Payment method' : 'طريقة الدفع',
                style: textBold.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF071B49),
                ),
              ),
              const SizedBox(height: 14),

              // Option 1: Cash on Delivery
              if (hasCod)
                _PaymentMethodRow(
                  title: isLtr ? 'Cash on delivery' : 'الدفع عند الاستلام',
                  subtitle: isLtr
                      ? 'Pay when your order arrives'
                      : 'ادفع عند استلام طلبك',
                  iconWidget: const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF015FC9),
                    size: 24,
                  ),
                  isSelected: checkout.isCODChecked,
                  isLtr: isLtr,
                  onTap: () => checkout.setOfflineChecked('cod'),
                ),

              if (hasCod && (hasWallet || localWallets.isNotEmpty))
                const SizedBox(height: 10),

              // Option 2: Available Wallet Balance
              if (hasWallet) ...[
                _PaymentMethodRow(
                  title: isLtr
                      ? 'Alline wallet balance'
                      : 'الرصيد المتاح في المحفظة',
                  subtitle: isLtr
                      ? 'Available balance: ${PriceConverter.convertPrice(context, balance)}'
                      : 'الرصيد المتاح: ${PriceConverter.convertPrice(context, balance)}',
                  extraWidget: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      walletIsEnough
                          ? (isLtr
                              ? 'Balance is sufficient to complete the order'
                              : 'الرصيد يكفي لإتمام الطلب')
                          : (isLtr
                              ? 'Balance is insufficient to complete the order'
                              : 'الرصيد غير كافٍ لإتمام الطلب'),
                      style: textBold.copyWith(
                        fontSize: 11.5,
                        color: walletIsEnough
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  iconWidget: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF015FC9),
                    size: 24,
                  ),
                  isSelected: checkout.isWalletChecked,
                  isLtr: isLtr,
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
                const SizedBox(height: 10),
              ],

              // Local payment is only selectable when the server returned an
              // enabled offline-payment method. This prevents a wallet choice
              // from being mapped to an unrelated method at index zero.
              if (localWallets.isNotEmpty)
                _PaymentMethodRow(
                  title: isLtr ? 'Local wallets' : 'المحافظ المحلية',
                  subtitle: checkout.isOfflineChecked &&
                          selectedWalletName.isNotEmpty
                      ? (isLtr
                          ? 'Selected: $selectedWalletName'
                          : 'المحفظة المختارة: $selectedWalletName')
                      : (isLtr
                          ? 'Choose approved wallet (Jeeb, Jawali, One Cash, ...)'
                          : 'اختر المحفظة المعتمدة (جيب، جوالي، ون كاش، ...)'),
                  extraWidget:
                      checkout.isOfflineChecked && selectedWalletName.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      selectedWalletLogo,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isLtr ? 'Tap to change' : 'اضغط للتغيير',
                                    style: textMedium.copyWith(
                                      fontSize: 11,
                                      color: const Color(0xFF015FC9),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                  iconWidget:
                      checkout.isOfflineChecked && selectedWalletName.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                selectedWalletLogo,
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFF015FC9),
                              size: 24,
                            ),
                  isSelected: checkout.isOfflineChecked,
                  isLtr: isLtr,
                  onTap: () {
                    _showLocalWalletsBottomSheet(
                      context,
                      checkout,
                      isLtr,
                      localWallets,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLocalWalletsBottomSheet(
    BuildContext context,
    CheckoutController checkout,
    bool isLtr,
    List<MapEntry<int, OfflineMethods>> localWallets,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4.5,
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
                      isLtr
                          ? 'Approved Local Wallets'
                          : 'المحافظ المحلية المعتمدة',
                      style: textBold.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF071B49),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment:
                        isLtr ? Alignment.centerLeft : Alignment.centerRight,
                    child: Text(
                      isLtr
                          ? 'Select an approved wallet to complete your payment'
                          : 'اختر المحفظة المعتمدة لإتمام دفع طلبك بكل سهولة وأمان',
                      style: textRegular.copyWith(
                        fontSize: 12.5,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...localWallets.expand((entry) {
                    final logo =
                        Images.getWalletLogo(entry.value.methodName ?? '') ??
                            Images.jeebWallet;
                    return [
                      _LocalWalletItemTile(
                        name: _cleanWalletName(
                            entry.value.methodName ?? '', isLtr),
                        description: isLtr
                            ? 'Pay with this local wallet'
                            : 'الدفع عبر هذه المحفظة المحلية',
                        logoAsset: logo,
                        isSelected: checkout.isOfflineChecked &&
                            checkout.offlineMethodSelectedIndex == entry.key,
                        onTap: () => _selectWallet(
                          bottomSheetContext,
                          checkout,
                          entry.key,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ];
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectWallet(
    BuildContext bottomSheetContext,
    CheckoutController checkout,
    int methodIndex,
  ) {
    checkout.setOfflineChecked('offline');
    checkout.setOfflinePaymentMethodSelectedIndex(methodIndex);
    Navigator.of(bottomSheetContext).pop();
  }

  List<MapEntry<int, OfflineMethods>> _supportedLocalWallets(
    List<OfflineMethods>? methods,
  ) {
    if (methods == null) return const [];
    return methods.asMap().entries.where((entry) {
      return entry.value.status == null || entry.value.status == 1;
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
        text.contains('jawwali')) return 'jawali';
    if (text.contains('ون كاش') ||
        text.contains('ونكاش') ||
        text.contains('one cash') ||
        text.contains('onecash')) return 'one_cash';
    if (text.contains('فلوسك') ||
        text.contains('floosak') ||
        text.contains('flousak')) return 'floosak';
    if (text.contains('كاش') || text.contains('cash')) return 'cash';
    return null;
  }

  String _selectedLocalWalletName(CheckoutController checkout, bool isLtr) {
    if (!checkout.isOfflineChecked) return '';
    final methods = checkout.offlinePaymentModel?.offlineMethods;
    if (methods != null &&
        checkout.offlineMethodSelectedIndex >= 0 &&
        checkout.offlineMethodSelectedIndex < methods.length) {
      final name =
          methods[checkout.offlineMethodSelectedIndex].methodName ?? '';
      final lower = name.toLowerCase();
      if (lower.contains('جيب') || lower.contains('jeeb')) {
        return isLtr ? 'Jeeb Wallet' : 'محفظة جيب';
      }
      if (lower.contains('جوالي') ||
          lower.contains('jawali') ||
          lower.contains('jawwali')) {
        return isLtr ? 'Jawali Wallet' : 'محفظة جوالي';
      }
      if (lower.contains('ون كاش') ||
          lower.contains('ونكاش') ||
          lower.contains('one cash') ||
          lower.contains('onecash')) {
        return isLtr ? 'One Cash Wallet' : 'محفظة ون كاش';
      }
      if (lower.contains('فلوسك') ||
          lower.contains('floosak') ||
          lower.contains('flousak')) {
        return isLtr ? 'Floosak Wallet' : 'محفظة فلوسك';
      }
      if ((lower.contains('كاش') || lower.contains('cash')) &&
          !lower.contains('استلام')) {
        return isLtr ? 'Cash Wallet' : 'محفظة كاش';
      }
      return name;
    }
    return isLtr ? 'Jeeb Wallet' : 'محفظة جيب';
  }

  String _selectedLocalWalletLogo(CheckoutController checkout) {
    final methods = checkout.offlinePaymentModel?.offlineMethods;
    if (methods != null &&
        checkout.offlineMethodSelectedIndex >= 0 &&
        checkout.offlineMethodSelectedIndex < methods.length) {
      final name =
          (methods[checkout.offlineMethodSelectedIndex].methodName ?? '')
              .toLowerCase();
      final logo = Images.getWalletLogo(name);
      if (logo != null) return logo;
    }
    return Images.jeebWallet;
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? extraWidget;
  final Widget iconWidget;
  final bool isSelected;
  final bool isLtr;
  final VoidCallback onTap;

  const _PaymentMethodRow({
    required this.title,
    required this.subtitle,
    this.extraWidget,
    required this.iconWidget,
    required this.isSelected,
    required this.isLtr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF4F8FE) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF015FC9)
                  : const Color(0xFFE1E8F2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Far Left in RTL / Left in LTR: Radio selection circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? const Color(0xFF015FC9) : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF015FC9)
                        : const Color(0xFFC7D5E8),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Middle: Title, Subtitle, and extra status info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF071B49),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textRegular.copyWith(
                        fontSize: 11.5,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                    if (extraWidget != null) extraWidget!,
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Far Right in RTL: Light blue icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: iconWidget),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalWalletItemTile extends StatelessWidget {
  final String name;
  final String description;
  final String logoAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocalWalletItemTile({
    required this.name,
    required this.description,
    required this.logoAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF4F8FE) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF015FC9)
                  : const Color(0xFFE1E8F2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? const Color(0xFF015FC9) : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF015FC9)
                        : const Color(0xFFC7D5E8),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF071B49),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: textRegular.copyWith(
                        fontSize: 11.5,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E8F2)),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      logoAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
