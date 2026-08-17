class GlobalProductPreviewModel {
  String? storeName;
  String? productUrl;
  String? title;
  String? thumbnail;
  List<String>? images;
  double? originalPrice;
  String? originalCurrency;
  double? estimatedWeightKg;
  double? airShippingCost;
  double? seaShippingCost;
  double? customsFee;
  double? serviceFee;
  double? totalEstimatedUsd;
  double? totalEstimatedYer;
  String? deliveryTimeAir;
  String? deliveryTimeSea;

  GlobalProductPreviewModel({
    this.storeName,
    this.productUrl,
    this.title,
    this.thumbnail,
    this.images,
    this.originalPrice,
    this.originalCurrency,
    this.estimatedWeightKg,
    this.airShippingCost,
    this.seaShippingCost,
    this.customsFee,
    this.serviceFee,
    this.totalEstimatedUsd,
    this.totalEstimatedYer,
    this.deliveryTimeAir,
    this.deliveryTimeSea,
  });

  factory GlobalProductPreviewModel.fromJson(Map<String, dynamic> json) {
    return GlobalProductPreviewModel(
      storeName: json['store_name'],
      productUrl: json['product_url'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      originalPrice: double.tryParse(json['original_price']?.toString() ?? '0') ?? 0.0,
      originalCurrency: json['original_currency'] ?? 'USD',
      estimatedWeightKg: double.tryParse(json['estimated_weight_kg']?.toString() ?? '0.5') ?? 0.5,
      airShippingCost: double.tryParse(json['air_shipping_cost']?.toString() ?? '0') ?? 0.0,
      seaShippingCost: double.tryParse(json['sea_shipping_cost']?.toString() ?? '0') ?? 0.0,
      customsFee: double.tryParse(json['customs_fee']?.toString() ?? '0') ?? 0.0,
      serviceFee: double.tryParse(json['service_fee']?.toString() ?? '0') ?? 0.0,
      totalEstimatedUsd: double.tryParse(json['total_estimated_usd']?.toString() ?? '0') ?? 0.0,
      totalEstimatedYer: double.tryParse(json['total_estimated_yer']?.toString() ?? '0') ?? 0.0,
      deliveryTimeAir: json['delivery_time_air'] ?? '7 - 12 days',
      deliveryTimeSea: json['delivery_time_sea'] ?? '25 - 35 days',
    );
  }
}
