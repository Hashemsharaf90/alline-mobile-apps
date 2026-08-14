class GlobalShoppingRequestModel {
  int? id;
  int? customerId;
  String? storeName;
  String? sourceHost;
  String? productUrl;
  int? quantity;
  String? customerNotes;
  String? status;
  int? approvedProductId;
  double? approvedPrice;
  String? quotedCurrency;
  String? createdAt;
  String? updatedAt;

  GlobalShoppingRequestModel({
    this.id,
    this.customerId,
    this.storeName,
    this.sourceHost,
    this.productUrl,
    this.quantity,
    this.customerNotes,
    this.status,
    this.approvedProductId,
    this.approvedPrice,
    this.quotedCurrency,
    this.createdAt,
    this.updatedAt,
  });

  factory GlobalShoppingRequestModel.fromJson(Map<String, dynamic> json) {
    return GlobalShoppingRequestModel(
      id: json['id'],
      customerId: json['customer_id'],
      storeName: json['store_name'],
      sourceHost: json['source_host'],
      productUrl: json['product_url'],
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : 1,
      customerNotes: json['customer_notes'],
      status: json['status'] ?? 'pending_pricing',
      approvedProductId: json['approved_product_id'],
      approvedPrice: double.tryParse((json['approved_price'] ?? json['quoted_price'])?.toString() ?? '0'),
      quotedCurrency: json['quoted_currency'] ?? 'YER',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
