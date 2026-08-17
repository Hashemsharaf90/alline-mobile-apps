import 'package:flutter_sixvalley_ecommerce/features/wallet/domain/models/local_wallet_method_model.dart';

class LocalWalletTopUpModel {
  int? id;
  double? amount;
  double? feeAmount;
  double? payableAmount;
  String? currencyCode;
  String? referenceCode;
  String? providerTransactionId;
  String? payerPhone;
  String? customerNote;
  String? adminNote;
  String? status;
  String? expiresAt;
  String? submittedAt;
  String? reviewedAt;
  LocalWalletMethodModel? method;

  LocalWalletTopUpModel({
    this.id,
    this.amount,
    this.feeAmount,
    this.payableAmount,
    this.currencyCode,
    this.referenceCode,
    this.providerTransactionId,
    this.payerPhone,
    this.customerNote,
    this.adminNote,
    this.status,
    this.expiresAt,
    this.submittedAt,
    this.reviewedAt,
    this.method,
  });

  LocalWalletTopUpModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    amount = _toDouble(json['amount']);
    feeAmount = _toDouble(json['fee_amount']) ?? 0;
    payableAmount = _toDouble(json['payable_amount']);
    currencyCode = json['currency_code'];
    referenceCode = json['reference_code'];
    providerTransactionId = json['provider_transaction_id'];
    payerPhone = json['payer_phone'];
    customerNote = json['customer_note'];
    adminNote = json['admin_note'];
    status = json['status'];
    expiresAt = json['expires_at'];
    submittedAt = json['submitted_at'];
    reviewedAt = json['reviewed_at'];
    method = json['method'] != null
        ? LocalWalletMethodModel.fromJson(json['method'])
        : null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse('$value');
  }
}
