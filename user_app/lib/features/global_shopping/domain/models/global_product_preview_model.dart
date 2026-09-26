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
    double? number(String key) =>
        json[key] == null ? null : double.tryParse(json[key].toString());
    return GlobalProductPreviewModel(
      storeName: json['store_name'],
      productUrl: json['product_url'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      originalPrice: number('original_price'),
      originalCurrency: json['original_currency'],
      estimatedWeightKg: number('estimated_weight_kg'),
      airShippingCost: number('air_shipping_cost'),
      seaShippingCost: number('sea_shipping_cost'),
      customsFee: number('customs_fee'),
      serviceFee: number('service_fee'),
      totalEstimatedUsd: number('total_estimated_usd'),
      totalEstimatedYer: number('total_estimated_yer'),
      deliveryTimeAir: json['delivery_time_air'],
      deliveryTimeSea: json['delivery_time_sea'],
    );
  }
}
