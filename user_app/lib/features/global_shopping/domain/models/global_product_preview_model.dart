class GlobalProductPreviewModel {
  String? storeName;
  String? productUrl;
  String? title;
  String? thumbnail;
  List<String>? images;
  double? originalPrice;
  double? currentPrice;
  double? convertedCurrentPrice;
  double? convertedOriginalPrice;
  double? exchangeRate;
  String? originalCurrency;
  String? convertedCurrency;
  String? feesStatus;

  GlobalProductPreviewModel({
    this.storeName,
    this.productUrl,
    this.title,
    this.thumbnail,
    this.images,
    this.originalPrice,
    this.currentPrice,
    this.convertedCurrentPrice,
    this.convertedOriginalPrice,
    this.exchangeRate,
    this.originalCurrency,
    this.convertedCurrency,
    this.feesStatus,
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
      currentPrice: number('current_price'),
      convertedCurrentPrice: number('converted_current_price'),
      convertedOriginalPrice: number('converted_original_price'),
      exchangeRate: number('exchange_rate'),
      originalCurrency: json['original_currency'],
      convertedCurrency: json['converted_currency'],
      feesStatus: json['fees_status'],
    );
  }
}
