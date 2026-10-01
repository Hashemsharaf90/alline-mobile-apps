class GlobalShoppingStoreModel {
  final String id;
  final String name;
  final String nameAr;
  final String domain;
  final String url;
  final String? logoUrl;
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
    this.logoUrl,
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
    final domain = json['domain']?.toString() ?? '';
    final url = _normalizeUrl(
      json['url']?.toString() ?? json['store_url']?.toString() ?? domain,
    );
    final rawLogo = (json['logo_url'] ?? json['logo'] ?? json['icon'])?.toString();
    final normalizedLogo = _normalizeUrl(rawLogo ?? '');
    final explicitSupport = json['request_supported'] ?? json['supported'];
    // Older deployed APIs returned a store directory with a domain and icon,
    // but no request_supported/url fields. The legacy request endpoint accepts
    // product URLs for those listed stores, so retain that manual flow.
    final requestSupported = explicitSupport is bool
        ? explicitSupport
        : domain.isNotEmpty;

    return GlobalShoppingStoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      domain: domain,
      url: url,
      logoUrl: normalizedLogo.isEmpty ? null : normalizedLogo,
      description: json['description']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      status: json['status']?.toString() ??
          (requestSupported ? 'request_only' : 'coming_soon'),
      statusLabelAr: json['status_label_ar']?.toString() ??
          (requestSupported ? 'طلب وتسعير يدوي' : 'قريباً'),
      requestSupported: requestSupported,
      manualPricing: json['manual_pricing'] == true,
      automaticImportSupported: json['automatic_import_supported'] == true,
      popular: json['popular'] == true,
    );
  }

  static String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.host.isNotEmpty) return uri.toString();
    }

    final uri = Uri.tryParse(
      trimmed.contains('://') ? trimmed : 'https://$trimmed',
    );
    if (uri == null || uri.host.isEmpty) return '';
    return uri.toString();
  }
}
