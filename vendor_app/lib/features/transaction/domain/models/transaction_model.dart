class TransactionModel {
  int? _id;
  int? _sellerId;
  int? _adminId;
  double? _amount;
  String? _transactionNote;
  int? _approved;
  String? _createdAt;
  String? _updatedAt;
  int? _withdrawalMethodId;
  Map<String, dynamic>? _withdrawalMethodFields;

  TransactionModel(
      {int? id,
        int? sellerId,
        int? adminId,
        double? amount,
        String? transactionNote,
        int? approved,
        String? createdAt,
        String? updatedAt}) {
    _id = id;
    _sellerId = sellerId;
    _adminId = adminId;
    _amount = amount;
    _transactionNote = transactionNote;
    _approved = approved;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  int? get id => _id;
  int? get sellerId => _sellerId;
  int? get adminId => _adminId;
  double? get amount => _amount;
  String? get transactionNote => _transactionNote;
  int? get approved => _approved;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get withdrawalMethodId => _withdrawalMethodId;
  Map<String, dynamic>? get withdrawalMethodFields => _withdrawalMethodFields;

  TransactionModel.fromJson(Map<String, dynamic> json) {
    _id = int.tryParse(json['id']?.toString() ?? '');
    _sellerId = int.tryParse(json['seller_id']?.toString() ?? '');
    _adminId = int.tryParse(json['admin_id']?.toString() ?? '');
    _amount = double.tryParse(json['amount']?.toString() ?? '');
    _transactionNote = json['transaction_note'];
    _approved = int.tryParse(json['approved']?.toString() ?? '');
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _withdrawalMethodId =
        int.tryParse(json['withdrawal_method_id']?.toString() ?? '');
    _withdrawalMethodFields = json['withdrawal_method_fields'] is Map
        ? Map<String, dynamic>.from(json['withdrawal_method_fields'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['seller_id'] = _sellerId;
    data['admin_id'] = _adminId;
    data['amount'] = _amount;
    data['transaction_note'] = _transactionNote;
    data['approved'] = _approved;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['withdrawal_method_id'] = _withdrawalMethodId;
    data['withdrawal_method_fields'] = _withdrawalMethodFields;
    return data;
  }
}
