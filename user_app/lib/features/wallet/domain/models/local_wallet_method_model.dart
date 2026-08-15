class LocalWalletMethodModel {
  int? id;
  String? name;
  String? code;
  String? merchantName;
  String? merchantAccount;
  String? logoUrl;
  String? instructions;
  double? minAmount;
  double? maxAmount;
  String? feeType;
  double? feeAmount;

  LocalWalletMethodModel({
    this.id,
    this.name,
    this.code,
    this.merchantName,
    this.merchantAccount,
    this.logoUrl,
    this.instructions,
    this.minAmount,
    this.maxAmount,
    this.feeType,
    this.feeAmount,
  });

  LocalWalletMethodModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    name = json['name'];
    code = json['code'];
    merchantName = json['merchant_name'];
    merchantAccount = json['merchant_account'];
    logoUrl = json['logo_url'];
    instructions = json['instructions'];
    minAmount = _toDouble(json['min_amount']);
    maxAmount = _toDouble(json['max_amount']);
    feeType = json['fee_type'];
    feeAmount = _toDouble(json['fee_amount']) ?? 0;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse('$value');
  }
}
