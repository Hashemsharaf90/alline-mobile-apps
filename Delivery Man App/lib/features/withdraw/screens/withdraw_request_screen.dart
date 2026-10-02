import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_delivery_boy/features/withdraw/controllers/withdraw_controller.dart';
import 'package:sixvalley_delivery_boy/helper/price_converter.dart';
import 'package:sixvalley_delivery_boy/helper/financial_input.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/bank_info_screen.dart';

class BalanceWithdrawScreen extends StatefulWidget {
  const BalanceWithdrawScreen({super.key});
  @override
  State<BalanceWithdrawScreen> createState() => _BalanceWithdrawScreenState();
}

class _BalanceWithdrawScreenState extends State<BalanceWithdrawScreen> {
  final amountController = TextEditingController(),
      noteController = TextEditingController();
  bool _confirming = false;
  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final profileController = Get.find<ProfileController>();
    final profile = profileController.profileModel;
    final withdraw = Get.find<WithdrawController>();
    if (_confirming || withdraw.isWithdraw) return;
    if (profile == null || profileController.profileLoadFailed) {
      showCustomSnackBarWidget('alline_wallet_error'.tr);
      return;
    }
    if (profile.accountNo == null || profile.accountNo!.isEmpty) {
      showCustomSnackBarWidget('bank_account_is_required'.tr);
      return;
    }
    if (!FinancialInput.canWithdraw(
        amountController.text, profile.withdrawableBalance)) {
      showCustomSnackBarWidget('alline_invalid_withdrawal'.tr);
      return;
    }
    final amount = FinancialInput.amount(amountController.text)!;
    setState(() => _confirming = true);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('send_withdraw_request'.tr),
                content: Text(PriceConverter.convertPrice(amount)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('cancel'.tr)),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('alline_confirm'.tr))
                ]));
    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirmed != true) return;
    final response = await withdraw.sendWithdrawRequest(
        amount.toString(), noteController.text.trim());
    if (response.statusCode == 200 && mounted) {
      amountController.clear();
      noteController.clear();
      await profileController.getProfile();
      Get.find<WalletController>().update();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBarWidget(title: 'withdraw'.tr, isBack: true),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child:
                          GetBuilder<ProfileController>(builder: (controller) {
                        final profile = controller.profileModel;
                        if (profile == null) {
                          return AllineErrorState(
                              message: 'alline_wallet_error'.tr,
                              onRetry: () => controller.getProfile());
                        }
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('total_withdrawable_balance'
                                                .tr),
                                            const SizedBox(height: 8),
                                            Text(
                                                PriceConverter.convertPrice(
                                                    profile
                                                        .withdrawableBalance),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium)
                                          ]))),
                              const SizedBox(height: 16),
                              Card(
                                  child: ListTile(
                                      leading: const Icon(
                                          Icons.account_balance_outlined),
                                      title: Text(profile.bankName ??
                                          'add_a_bank_account'.tr),
                                      subtitle: Text(
                                          FinancialInput.maskAccount(
                                              profile.accountNo),
                                          textDirection: TextDirection.ltr),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => Get.to(
                                          () => const BankInfoScreen()))),
                              const SizedBox(height: 24),
                              TextField(
                                  controller: amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  textDirection: TextDirection.ltr,
                                  decoration: InputDecoration(
                                      labelText: 'withdraw_amount'.tr,
                                      hintText: 'enter_amount'.tr)),
                              const SizedBox(height: 16),
                              TextField(
                                  controller: noteController,
                                  minLines: 2,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                      labelText: 'remark'.tr,
                                      hintText: 'remark_text'.tr)),
                              const SizedBox(height: 24),
                              GetBuilder<WithdrawController>(
                                  builder: (withdraw) => ElevatedButton(
                                      onPressed:
                                          withdraw.isWithdraw || _confirming
                                              ? null
                                              : _send,
                                      child: withdraw.isWithdraw
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))
                                          : Text('send_withdraw_request'.tr,
                                              textAlign: TextAlign.center))),
                            ]);
                      }))))));
}
