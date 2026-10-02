import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_edit_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class WithdrawBalanceWidget extends StatelessWidget {
  const WithdrawBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<ProfileController>().userInfoModel?.wallet;
    final walletController = context.watch<WalletController>();
    final balance = wallet?.totalEarning ?? 0;
    final hasWithdrawalMethod = walletController.methodList.isNotEmpty ||
        walletController.myMethodsIds.isNotEmpty;
    final isLoadingMethods = walletController.isLoadingWithdrawMethods ||
        walletController.isLoadingPaymentInfo;
    final canWithdraw = balance > 0 && hasWithdrawalMethod;
    final updatedAt = DateTime.tryParse(wallet?.updatedAt ?? '');

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AllineColors.primary, AllineColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primary.withValues(alpha: .16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -72,
            end: -42,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'محفظة متجرك',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'AllineTajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.verified_user_outlined,
                        color: Colors.white70, size: 19),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'الرصيد المتاح لطلب السحب',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    PriceConverter.convertPrice(context, balance),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'AllineTajawal',
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (balance <= 0)
                  Text(
                    'سيظهر رصيدك هنا بعد استحقاق مبالغ الطلبات.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .78),
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                    ),
                  ),
                if (updatedAt != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    'آخر تحديث: ${DateConverter.localDateToIsoStringAMPMOrder(updatedAt.toLocal()).trim()}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .7),
                      fontFamily: 'AllineTajawal',
                      fontSize: 10,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: !isLoadingMethods && canWithdraw
                        ? () => showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (_) => CustomEditDialogWidget(
                                totalEarning: balance,
                              ),
                            )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AllineColors.primary,
                      disabledBackgroundColor: Colors.white.withValues(alpha: .45),
                      disabledForegroundColor: AllineColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: isLoadingMethods
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.north_east_rounded, size: 18),
                    label: Text(
                      isLoadingMethods
                          ? 'جارٍ تحميل طرق السحب…'
                          : 'طلب سحب',
                    ),
                  ),
                ),
                if (!isLoadingMethods && !hasWithdrawalMethod) ...[
                  const SizedBox(height: 8),
                  Text(
                    walletController.withdrawMethodLoadFailed ||
                            walletController.paymentInfoLoadFailed
                        ? 'تعذر تحميل طرق السحب. حدّث الصفحة للمحاولة مجددًا.'
                        : 'لا تتوفر طريقة سحب حاليًا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .8),
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
