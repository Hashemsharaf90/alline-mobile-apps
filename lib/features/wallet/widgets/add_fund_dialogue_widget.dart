import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/custom_check_box_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/domain/models/local_wallet_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AddFundDialogueWidget extends StatefulWidget {
  const AddFundDialogueWidget({
    super.key,
    required this.focusNode,
    required this.inputAmountController,
  });

  final FocusNode focusNode;
  final TextEditingController inputAmountController;

  @override
  State<AddFundDialogueWidget> createState() => _AddFundDialogueWidgetState();
}

class _AddFundDialogueWidgetState extends State<AddFundDialogueWidget> {
  final TextEditingController transactionIdController = TextEditingController();
  final TextEditingController payerPhoneController = TextEditingController();
  final TextEditingController customerNoteController = TextEditingController();

  @override
  void dispose() {
    transactionIdController.dispose();
    payerPhoneController.dispose();
    customerNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
          child: Consumer<CheckoutController>(
            builder: (context, digitalPaymentProvider, _) {
              return Consumer<SplashController>(
                builder: (context, configProvider, _) {
                  final bool hasOnlinePayment =
                      (configProvider.configModel?.digitalPayment ?? false) &&
                          (configProvider
                                  .configModel?.paymentMethods?.isNotEmpty ??
                              false);

                  return Consumer<WalletController>(
                    builder: (context, walletController, _) {
                      return SingleChildScrollView(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeDefault),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeSmall,
                                  Dimensions.paddingSizeExtraLarge,
                                  Dimensions.paddingSizeSmall,
                                  Dimensions.paddingSizeDefault,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getTranslated(
                                          'add_fund_to_wallet', context)!,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeSmall,
                                        bottom: Dimensions.paddingSizeDefault,
                                      ),
                                      child: Text(
                                        'Add balance using a local Yemeni wallet code, or use online payment if available.',
                                        style: textRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withValues(alpha: 0.5),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    _AmountBox(
                                      inputAmountController:
                                          widget.inputAmountController,
                                      currencySymbol:
                                          configProvider.myCurrency?.symbol ??
                                              '\$',
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeDefault),
                                    _buildLocalWalletSection(
                                        context, walletController),
                                    if (hasOnlinePayment) ...[
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      _buildOnlinePaymentSection(
                                        context,
                                        configProvider,
                                        digitalPaymentProvider,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.20),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeExtraSmall),
                                  child: Icon(
                                    Icons.close,
                                    size: Dimensions.iconSizeSmall,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLocalWalletSection(
      BuildContext context, WalletController walletController) {
    final localWallets = walletController.localWalletMethods;
    final selectedMethod = walletController.selectedLocalWalletMethod;
    final topUp = walletController.createdLocalWalletTopUp;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeTwelve),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  'Local wallet top-up',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (walletController.isLocalWalletLoading)
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'Generate a code, transfer the amount from your wallet app, then enter the transaction ID for admin approval.',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (!walletController.isLocalWalletLoading && localWallets.isEmpty)
            Text(
              'No local wallets are active right now.',
              style: textRegular.copyWith(color: Theme.of(context).hintColor),
            )
          else ...[
            DropdownButtonFormField<int>(
              initialValue: selectedMethod?.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Wallet',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
              ),
              items: localWallets.map((method) {
                return DropdownMenuItem<int>(
                  value: method.id,
                  child: Text(method.name ?? 'Local wallet'),
                );
              }).toList(),
              onChanged: walletController.setSelectedLocalWalletMethod,
            ),
            if (selectedMethod != null) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _MethodInfoBox(method: selectedMethod),
            ],
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomButton(
              buttonText: topUp == null
                  ? 'Generate payment code'
                  : 'Generate another code',
              isLoading:
                  walletController.isLocalTopUpSubmitting && topUp == null,
              onTap: () => _createLocalTopUp(context, walletController),
            ),
            if (topUp != null) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _GeneratedCodeBox(referenceCode: topUp.referenceCode ?? ''),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _InfoRow(
                  title: 'Payable amount',
                  value: _formatAmount(topUp.payableAmount ?? topUp.amount)),
              _InfoRow(
                  title: 'Status',
                  value: (topUp.status ?? '').replaceAll('_', ' ')),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              TextField(
                controller: transactionIdController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Wallet transaction ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              TextField(
                controller: payerPhoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Sender phone (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              TextField(
                controller: customerNoteController,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomButton(
                buttonText: 'Submit for review',
                isLoading: walletController.isLocalTopUpSubmitting,
                onTap: () => _confirmLocalTopUp(context, walletController),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildOnlinePaymentSection(
    BuildContext context,
    SplashController configProvider,
    CheckoutController digitalPaymentProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor, width: 1),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeTwelve),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              getTranslated('add_money_via_online', context)!,
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: configProvider.configModel?.paymentMethods?.length ?? 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final method = configProvider.configModel!.paymentMethods![index];
              return CustomCheckBoxWidget(
                index: index,
                icon:
                    '${configProvider.configModel?.paymentMethodImagePath}/${method.additionalDatas?.gatewayImage ?? ''}',
                name: method.keyName ?? '',
                title: method.additionalDatas?.gatewayTitle ?? '',
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CustomButton(
              buttonText: getTranslated('add_fund', context)!,
              onTap: () {
                if (digitalPaymentProvider
                    .selectedDigitalPaymentMethodName.isEmpty) {
                  digitalPaymentProvider.setDigitalPaymentMethodName(
                    0,
                    configProvider.configModel!.paymentMethods![0].keyName!,
                  );
                }
                if (!_isValidAmount(context)) {
                  return;
                }
                if (digitalPaymentProvider.paymentMethodIndex == -1) {
                  showCustomSnackBarWidget(
                    getTranslated('please_select_any_payment_type', context),
                    context,
                    snackBarType: SnackBarType.warning,
                  );
                  return;
                }

                Provider.of<WalletController>(context, listen: false)
                    .addFundToWallet(
                  widget.inputAmountController.text.trim(),
                  digitalPaymentProvider.selectedDigitalPaymentMethodName,
                )
                    .then((response) {
                  widget.inputAmountController.clear();
                  Navigator.pop(Get.context!);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createLocalTopUp(
      BuildContext context, WalletController walletController) async {
    if (!_isValidAmount(context)) {
      return;
    }
    await walletController.createLocalWalletTopUpRequest(
      widget.inputAmountController.text.trim(),
      context,
    );
  }

  Future<void> _confirmLocalTopUp(
      BuildContext context, WalletController walletController) async {
    if (transactionIdController.text.trim().isEmpty) {
      showCustomSnackBarWidget(
          'Please enter the wallet transaction ID', context,
          snackBarType: SnackBarType.warning);
      return;
    }

    final bool success = await walletController.confirmLocalWalletTopUpRequest(
      transactionId: transactionIdController.text.trim(),
      payerPhone: payerPhoneController.text,
      customerNote: customerNoteController.text,
      context: context,
    );

    if (success && mounted) {
      widget.inputAmountController.clear();
      transactionIdController.clear();
      payerPhoneController.clear();
      customerNoteController.clear();
    }
  }

  bool _isValidAmount(BuildContext context) {
    if (widget.inputAmountController.text.trim().isEmpty) {
      showCustomSnackBarWidget(
          getTranslated('please_input_amount', context), context,
          snackBarType: SnackBarType.warning);
      return false;
    }

    final amount =
        double.tryParse(widget.inputAmountController.text.trim()) ?? 0;
    if (amount <= 0) {
      showCustomSnackBarWidget(
          getTranslated('please_input_amount', context), context,
          snackBarType: SnackBarType.warning);
      return false;
    }
    return true;
  }

  String _formatAmount(double? amount) {
    if (amount == null) {
      return '--';
    }
    return PriceConverter.convertPrice(context, amount);
  }
}

class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.inputAmountController,
    required this.currencySymbol,
  });

  final TextEditingController inputAmountController;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.homePagePadding),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeTwelve),
      ),
      child: SizedBox(
        width: 220,
        child: TextField(
          controller: inputAmountController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
          ],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex 15000',
            hintStyle: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.homePagePadding,
                right: Dimensions.paddingSizeEight,
              ),
              child: Text(
                currencySymbol,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeTwelve),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.homePagePadding,
              vertical: Dimensions.paddingSizeDefaultAddress,
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodInfoBox extends StatelessWidget {
  const _MethodInfoBox({required this.method});

  final LocalWalletMethodModel method;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
              title: 'Merchant',
              value: method.merchantName ?? method.name ?? '--'),
          _InfoRow(
              title: 'Account',
              value: method.merchantAccount?.isNotEmpty == true
                  ? method.merchantAccount!
                  : '--'),
          if ((method.instructions ?? '').isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              method.instructions!,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ],
        ],
      ),
    );
  }
}

class _GeneratedCodeBox extends StatelessWidget {
  const _GeneratedCodeBox({required this.referenceCode});

  final String referenceCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reference code',
                    style: textRegular.copyWith(
                        color: Theme.of(context).hintColor)),
                Text(referenceCode,
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: referenceCode));
              if (context.mounted) {
                showCustomSnackBarWidget('Code copied', context);
              }
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(title,
                style:
                    textRegular.copyWith(color: Theme.of(context).hintColor)),
          ),
          Expanded(child: Text(value, style: textMedium)),
        ],
      ),
    );
  }
}
