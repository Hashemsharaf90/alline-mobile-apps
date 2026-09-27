class GlobalShoppingStoreModel {
  final String id;
  final String name;
  final String nameAr;
  final String domain;
  final String url;
  final String description;
  final String descriptionAr;
  final String status;
  final String statusLabelAr;
  final bool requestSupported;
  final bool manualPricing;
  final bool automaticImportSupported;
  final bool popular;

  const GlobalShoppingStoreModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.domain,
    required this.url,
    required this.description,
    required this.descriptionAr,
    required this.status,
    required this.statusLabelAr,
    required this.requestSupported,
    required this.manualPricing,
    required this.automaticImportSupported,
    required this.popular,
  });

  bool get isComingSoon => status == 'coming_soon' || !requestSupported;

  factory GlobalShoppingStoreModel.fromJson(Map<String, dynamic> json) {
    return GlobalShoppingStoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      status: json['status']?.toString() ?? 'coming_soon',
      statusLabelAr: json['status_label_ar']?.toString() ?? 'قريباً',
      requestSupported: json['request_supported'] == true,
      manualPricing: json['manual_pricing'] == true,
      automaticImportSupported: json['automatic_import_supported'] == true,
      popular: json['popular'] == true,
    );
  }
}
