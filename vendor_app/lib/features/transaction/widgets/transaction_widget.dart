import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/domain/models/transaction_model.dart';
import 'package:sixvalley_vendor_app/features/transaction/widgets/transaction_details_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class TransactionWidget extends StatelessWidget {
  final TransactionModel transactionModel;
  const TransactionWidget({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(context, transactionModel.approved);
    final isPending = transactionModel.approved == 0;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 5),
      decoration: BoxDecoration(
        color: ColorResources.getCardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.getBorder(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(13, 13, 13, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AllineColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.south_west_rounded,
                        color: AllineColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب سحب #${transactionModel.id ?? '—'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorResources.getTextTitle(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'AllineTajawal',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(transactionModel.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorResources.getTextSubTitle(context),
                              fontSize: 11,
                              fontFamily: 'AllineTajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          PriceConverter.convertPrice(
                            context,
                            transactionModel.amount ?? 0,
                          ),
                          style: TextStyle(
                            color: ColorResources.getTextTitle(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'AllineTajawal',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(status.icon, color: status.color, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            status.label,
                            style: TextStyle(
                              color: status.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'AllineTajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isPending)
                      TextButton.icon(
                        onPressed: () => cancelTransaction(
                          context,
                          transactionModel,
                        ),
                        icon: const Icon(Icons.close_rounded, size: 15),
                        label: Text(
                          getTranslated('cancel', context) ?? 'إلغاء الطلب',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: ColorResources.getTextSubTitle(context),
                          minimumSize: const Size(44, 36),
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          textStyle: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (!isPending)
                      Text(
                        getTranslated('view_details', context) ?? 'عرض التفاصيل',
                        style: TextStyle(
                          color: ColorResources.getTextSubTitle(context),
                          fontSize: 11,
                          fontFamily: 'AllineTajawal',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (_) => Wrap(
        children: [TransactionDetailsWidget(transactionModel: transactionModel)],
      ),
    );
  }
}

class _TransactionStatusPresentation {
  const _TransactionStatusPresentation(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

_TransactionStatusPresentation _statusPresentation(
  BuildContext context,
  int? approved,
) {
  if (approved == 1) {
    return _TransactionStatusPresentation(
      getTranslated('approved', context) ?? 'تمت الموافقة',
      AllineColors.success,
      Icons.check_circle_outline_rounded,
    );
  }
  if (approved == 2) {
    return _TransactionStatusPresentation(
      getTranslated('denied', context) ?? 'مرفوض',
      AllineColors.error,
      Icons.cancel_outlined,
    );
  }
  return _TransactionStatusPresentation(
    getTranslated('pending', context) ?? 'قيد المراجعة',
    AllineColors.warning,
    Icons.schedule_rounded,
  );
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  try {
    return DateConverter.isoStringToDateTimeString(value);
  } catch (_) {
    final date = DateTime.tryParse(value);
    return date == null ? '—' : DateConverter.localDateToIsoStringAMPMOrder(date);
  }
}

void cancelTransaction(BuildContext context, TransactionModel transactionModel) {
  final pageContext = context;
  showDialog<void>(
    context: pageContext,
    barrierDismissible: false,
    builder: (dialogContext) => Consumer<WalletController>(
      builder: (context, walletController, child) => ConfirmationDialogWidget(
        icon: Images.deleteIcon,
        description: getTranslated('are_you_sure_you_want', context),
        refund: false,
        isLoading: walletController.isLoading,
        onYesPressed: () async {
          if (walletController.isLoading) return;
          final response = await walletController.closeWithdrawRequest(
            transactionModel.id ?? 0,
            transactionModel.amount?.toString() ?? '0',
            context: pageContext,
          );
          if (response.response?.statusCode == 200 &&
              dialogContext.mounted &&
              pageContext.mounted) {
            Navigator.of(dialogContext).pop();
            Provider.of<TransactionController>(pageContext, listen: false)
                .getTransactionList(pageContext, 'all', '', '');
            showCustomSnackBarWidget(
              getTranslated('withdraw_request_deleted', pageContext),
              pageContext,
              isError: false,
            );
          }
        },
      ),
    ),
  );
}
