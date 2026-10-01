import 'package:flutter/material.dart';

class GlobalShowcaseProduct {
  final String id;
  final String name;
  final String nameEn;
  final String store;
  final String category;
  final String categoryEn;
  final double priceUsd;
  final double? originalPriceUsd;
  final String imageUrl;
  final List<String> galleryImages;
  final double rating;
  final int reviewsCount;
  final String productUrl;
  final String description;
  final String descriptionEn;
  final List<String> features;
  final String? badge;
  final Color? badgeColor;

  const GlobalShowcaseProduct({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.store,
    required this.category,
    required this.categoryEn,
    required this.priceUsd,
    this.originalPriceUsd,
    required this.imageUrl,
    this.galleryImages = const [],
    this.rating = 4.8,
    this.reviewsCount = 120,
    required this.productUrl,
    required this.description,
    required this.descriptionEn,
    this.features = const [],
    this.badge,
    this.badgeColor,
  });

  /// Approximate price in Yemeni Rials (YER) based on an estimated rate of 535 YER/USD
  int get approxYerPrice => (priceUsd * 535).round();

  /// Approximate original price in Yemeni Rials (YER)
  int? get approxOriginalYerPrice =>
      originalPriceUsd != null ? (originalPriceUsd! * 535).round() : null;

  /// Percentage discount if originalPriceUsd is set
  int? get discountPercent {
    if (originalPriceUsd == null || originalPriceUsd! <= priceUsd) return null;
    return (((originalPriceUsd! - priceUsd) / originalPriceUsd!) * 100).round();
  }
}

class GlobalShowcaseRepository {
  static const List<GlobalShowcaseProduct> curatedProducts = [
    // 1. Amazon - Apple AirPods Pro 2
    GlobalShowcaseProduct(
      id: 'amz_airpods_pro_2',
      name: 'سماعات Apple AirPods Pro (الجيل الثاني) مع علبة شحن MagSafe بمنفذ USB-C',
      nameEn: 'Apple AirPods Pro (2nd Gen) with MagSafe Case (USB-C)',
      store: 'Amazon',
      category: 'إلكترونيات',
      categoryEn: 'Electronics',
      priceUsd: 189.99,
      originalPriceUsd: 249.00,
      imageUrl: 'https://m.media-amazon.com/images/I/61SUj2aKoEL._AC_SL1500_.jpg',
      galleryImages: [
        'https://m.media-amazon.com/images/I/61SUj2aKoEL._AC_SL1500_.jpg',
        'https://m.media-amazon.com/images/I/51bRSWrMm7L._AC_SL1500_.jpg',
        'https://m.media-amazon.com/images/I/61T2lZ25XKL._AC_SL1500_.jpg',
      ],
      rating: 4.8,
      reviewsCount: 142000,
      productUrl: 'https://www.amazon.com/dp/B0CHWRXH8B',
      badge: 'الأكثر مبيعاً',
      badgeColor: Color(0xFFEC970D),
      description:
          'سماعات Apple AirPods Pro الجيل الثاني تقدم تجربة صوتية رائدة مع تقنية إلغاء الضوضاء النشط حتى ضعفي الجيل السابق، ووضع الشفافية التكيفي، وصوت مكاني مخصص يحيط بك من كل جهة.',
      descriptionEn:
          'Up to 2x more Active Noise Cancellation, Adaptive Audio, Personalized Spatial Audio, and MagSafe Charging Case (USB-C).',
      features: [
        'إلغاء ضوضاء نشط مضاعف وصوت فائق النقاء',
        'علبة MagSafe بمنفذ Type-C وسماعة للعثور عليها',
        'مقاومة الماء والغبار بمعيار IP54',
        'بطارية تدوم حتى 30 ساعة مع العلبة',
      ],
    ),

    // 2. Amazon - Anker 737 Power Bank
    GlobalShowcaseProduct(
      id: 'amz_anker_737',
      name: 'شاحن متنقل Anker 737 Power Bank بسعة 24,000mAh وقدرة شحن فائقة 140W',
      nameEn: 'Anker 737 Power Bank (PowerCore 24K) 140W 24,000mAh',
      store: 'Amazon',
      category: 'إلكترونيات',
      categoryEn: 'Electronics',
      priceUsd: 109.99,
      originalPriceUsd: 149.99,
      imageUrl: 'https://m.media-amazon.com/images/I/61Nl8q2V2cL._AC_SL1500_.jpg',
      galleryImages: [
        'https://m.media-amazon.com/images/I/61Nl8q2V2cL._AC_SL1500_.jpg',
        'https://m.media-amazon.com/images/I/71u9zN5q2tL._AC_SL1500_.jpg',
      ],
      rating: 4.7,
      reviewsCount: 12500,
      productUrl: 'https://www.amazon.com/dp/B09VPHVT2Z',
      badge: 'اختيار Alline',
      badgeColor: Color(0xFF015FC9),
      description:
          'بنك طاقة جبار من أنكر يشحن أجهزة اللابتوب والهواتف بأقصى سرعة ممكنة 140W بفضل منفذ Power Delivery 3.1 وشاشة ملونة تعرض كافة تفاصيل الشحن.',
      descriptionEn:
          'High-speed 140W two-way charging with smart digital display and massive 24,000mAh capacity.',
      features: [
        'قدرة 140W لشحن ماك بوك ولابتوبات الألعاب',
        'شاشة رقمية تفاعلية توضح سرعة الدخل والخرج',
        'إمكانية شحن 3 أجهزة في وقت واحد',
        'نظام حماية ذكي متعدد ActiveShield 2.0',
      ],
    ),

    // 3. Amazon - Philips OneBlade 360
    GlobalShowcaseProduct(
      id: 'amz_philips_oneblade',
      name: 'ماكينة الحلاقة والتشذيب الذكية للوجه والجسم Philips OneBlade 360 Face & Body',
      nameEn: 'Philips Norelco OneBlade 360 Face + Body',
      store: 'Amazon',
      category: 'عناية ومنزل',
      categoryEn: 'Personal Care',
      priceUsd: 39.96,
      originalPriceUsd: 49.99,
      imageUrl: 'https://m.media-amazon.com/images/I/71u9sW4jQYL._AC_SL1500_.jpg',
      galleryImages: [
        'https://m.media-amazon.com/images/I/71u9sW4jQYL._AC_SL1500_.jpg',
      ],
      rating: 4.6,
      reviewsCount: 46000,
      productUrl: 'https://www.amazon.com/dp/B0BR7JCGDT',
      badge: 'تقييم ممتاز',
      badgeColor: Color(0xFF18A957),
      description:
          'ماكينة ثورية تدمج التشذيب والحلاقة لأي طول للشعر دون تهيج البشرة، بشفرة 360 مبتكرة تتحرك في كافة الاتجاهات.',
      descriptionEn:
          'Revolutionary grooming technology with 360-degree blade designed to trim, edge, and shave any length of hair.',
      features: [
        'شفرة 360 تتبع انحناءات الوجه بدقة وسلاسة',
        'مقاومة تامة للماء للاستخدام الجاف أو مع رغوة الحلاقة',
        'رؤوس تشذيب متعددة وملحقات للجسم والمناطق الحساسة',
      ],
    ),

    // 4. Amazon - Kindle Paperwhite 16GB
    GlobalShowcaseProduct(
      id: 'amz_kindle_paperwhite',
      name: 'قارئ الكتب الإلكترونية Kindle Paperwhite شاشة 6.8 بوصة إضاءة دافئة 16GB',
      nameEn: 'Kindle Paperwhite (16 GB) 6.8" display with adjustable warm light',
      store: 'Amazon',
      category: 'إلكترونيات',
      categoryEn: 'Electronics',
      priceUsd: 149.99,
      originalPriceUsd: 169.99,
      imageUrl: 'https://m.media-amazon.com/images/I/51qcKc85NEL._AC_SL1000_.jpg',
      galleryImages: [
        'https://m.media-amazon.com/images/I/51qcKc85NEL._AC_SL1000_.jpg',
      ],
      rating: 4.7,
      reviewsCount: 31000,
      productUrl: 'https://www.amazon.com/dp/B08KTZ8249',
      badge: 'لعشاق القراءة',
      badgeColor: Color(0xFF6852C8),
      description:
          'شاشة حبر إلكتروني نقية بدقة 300ppi تبدو مثل الورق الحقيقي دون أي انعكاس للشمس، مع بطارية تدوم حتى 10 أسابيع ومقاومة تامة للماء.',
      descriptionEn:
          'Now with a 6.8" display and thinner borders, adjustable warm light, up to 10 weeks of battery life, and 20% faster page turns.',
      features: [
        'شاشة مريحة للعين ليلاً ونهاراً بدون إجهاد',
        'مقاوم للماء بدرجة IPX8',
        'شحن سريع عبر منفذ USB-C',
      ],
    ),

    // 5. SHEIN - Elegant Floral Dress
    GlobalShowcaseProduct(
      id: 'shein_floral_dress',
      name: 'فستان ميدي نسائي أنيق بطبعة زهور كلاسيكية وحزام خصر متناسق',
      nameEn: 'SHEIN Floral Print Belted A-line Midi Dress',
      store: 'SHEIN',
      category: 'أزياء',
      categoryEn: 'Fashion',
      priceUsd: 16.49,
      originalPriceUsd: 23.00,
      imageUrl: 'https://img.ltwebstatic.com/images3_pi/2023/05/18/1684398114c00d41e21e695b225330364e08cfeb78_thumbnail_900x.webp',
      galleryImages: [
        'https://img.ltwebstatic.com/images3_pi/2023/05/18/1684398114c00d41e21e695b225330364e08cfeb78_thumbnail_900x.webp',
      ],
      rating: 4.8,
      reviewsCount: 9400,
      productUrl: 'https://ar.shein.com/women-dresses-c-1727.html',
      badge: 'ترند الموضة',
      badgeColor: Color(0xFFEC970D),
      description:
          'فستان أنيق مصنوع من خامة باردة ومريحة تناسب أجواء الصيف والمناسبات العائلية، بتصميم انسيابي جذاب.',
      descriptionEn:
          'Chic and flattering A-line dress with romantic floral print and detachable belt.',
      features: [
        'خامة ناعمة خفيفة وانسيابية',
        'قصة ملائمة لمختلف المقاسات مع حزام ربط',
        'سهل الغسيل والعناية',
      ],
    ),

    // 6. SHEIN - Premium Handbag
    GlobalShowcaseProduct(
      id: 'shein_lux_bag',
      name: 'حقيبة يد نسائية فاخرة بتصميم مضلع مع حزام كتف أنيق وسحاب معدني ذهبي',
      nameEn: 'SHEIN Quilted Pattern Structured Shoulder Bag',
      store: 'SHEIN',
      category: 'أزياء',
      categoryEn: 'Fashion',
      priceUsd: 12.99,
      originalPriceUsd: 18.50,
      imageUrl: 'https://img.ltwebstatic.com/images3_pi/2023/08/21/58/1692601726a4574cbf5e1564f336630f69bc820790_thumbnail_900x.webp',
      galleryImages: [
        'https://img.ltwebstatic.com/images3_pi/2023/08/21/58/1692601726a4574cbf5e1564f336630f69bc820790_thumbnail_900x.webp',
      ],
      rating: 4.9,
      reviewsCount: 16800,
      productUrl: 'https://ar.shein.com/women-bags-c-1764.html',
      badge: 'الأكثر طلباً',
      badgeColor: Color(0xFFD9363E),
      description:
          'حقيبة بتصميم راقٍ يناسب الإطلالات اليومية والمسائية، بمساحة رحبة تتسع لهاتفك ومحفظتك وأدواتك الشخصية.',
      descriptionEn:
          'Quilted texture with polished gold-tone hardware and versatile carry handles.',
      features: [
        'جلد نباتي PU متين ومقاوم للخدش',
        'جيوب داخلية متعددة لتنظيم الأغراض',
        'حزام كتف إضافي قابل للتعديل والفصل',
      ],
    ),

    // 7. AliExpress - Smart Tactical Watch
    GlobalShowcaseProduct(
      id: 'ali_military_watch',
      name: 'ساعة ذكية تكتيكية AMOLED عسكرية تدعم المكالمات وبطارية تدوم طويلاً',
      nameEn: 'Military AMOLED Rugged Smartwatch with Bluetooth Calling',
      store: 'AliExpress',
      category: 'إلكترونيات',
      categoryEn: 'Electronics',
      priceUsd: 26.80,
      originalPriceUsd: 48.00,
      imageUrl: 'https://ae-pic-a1.aliexpress-media.com/kf/S1bf52c42c92e4ba98fb83713f06e5beff.jpg',
      galleryImages: [
        'https://ae-pic-a1.aliexpress-media.com/kf/S1bf52c42c92e4ba98fb83713f06e5beff.jpg',
      ],
      rating: 4.8,
      reviewsCount: 21300,
      productUrl: 'https://www.aliexpress.com/item/1005005872166548.html',
      badge: 'صفقة خارقة',
      badgeColor: Color(0xFFEC970D),
      description:
          'ساعة ذكية قوية مجهزة بشاشة فائقة الدقة AMOLED وتصميم مدرع يتحمل الصدمات، مع دعم كامل للغة العربية والإشعارات والمكالمات الهاتفية.',
      descriptionEn:
          'Heavy-duty rugged smartwatch featuring 1.43" AMOLED screen, Bluetooth call, 100+ sports modes, and long battery life.',
      features: [
        'شاشة AMOLED ساطعة بدقة عالية Always-on Display',
        'مكالمات بلوتوث مباشرة مع مايك وسماعة صوت واضحة',
        'قياس نبضات القلب ونسبة الأكسجين ومراقبة النوم',
        'مقاومة تامة للمياه والغبار IP68',
      ],
    ),

    // 8. AliExpress - 4K Dual Camera Drone
    GlobalShowcaseProduct(
      id: 'ali_drone_4k',
      name: 'طائرة درون ذكية قابلة للطي بكاميرا مزدوجة بدقة 4K ونظام تجنب العوائق',
      nameEn: '4K Dual Camera Foldable Drone with Obstacle Avoidance',
      store: 'AliExpress',
      category: 'إلكترونيات',
      categoryEn: 'Electronics',
      priceUsd: 34.50,
      originalPriceUsd: 65.00,
      imageUrl: 'https://ae-pic-a1.aliexpress-media.com/kf/Sf65b6e4ef50942549a933f27f8a855909.jpg',
      galleryImages: [
        'https://ae-pic-a1.aliexpress-media.com/kf/Sf65b6e4ef50942549a933f27f8a855909.jpg',
      ],
      rating: 4.6,
      reviewsCount: 7400,
      productUrl: 'https://www.aliexpress.com/item/1005006129845123.html',
      badge: 'الأعلى طلباً',
      badgeColor: Color(0xFF015FC9),
      description:
          'درون سهل التحكم للمبتدئين والمحترفين، مزود بمستشعرات ذكية لتجنب الاصطدام، وكاميرا 4K تمنحك زوايا تصوير جوي استثنائية.',
      descriptionEn:
          'Intelligent obstacle sensing, 4K HD dual camera, altitude hold, headless mode, and compact folding design.',
      features: [
        'بث فيديو مباشر إلى هاتفك بدقة HD عبر Wi-Fi',
        'مستشعر ذكي رباعي لتفادي الجدران والعوائق تلقائياً',
        'إقلاع وهبوط بلمسة زر واحدة وميزة العودة للمنزل',
      ],
    ),

    // 9. AliExpress - Anti-theft Backpack
    GlobalShowcaseProduct(
      id: 'ali_antitheft_bag',
      name: 'حقيبة ظهر ذكية مضادة للسرقة والماء مع قفل أمان ومنفذ شحن USB',
      nameEn: 'Waterproof Anti-Theft Laptop Backpack with USB Port & Lock',
      store: 'AliExpress',
      category: 'اكسسوارات',
      categoryEn: 'Accessories',
      priceUsd: 19.90,
      originalPriceUsd: 32.00,
      imageUrl: 'https://ae-pic-a1.aliexpress-media.com/kf/S32dff424da2b489a81284d72851a0219Q.jpg',
      galleryImages: [
        'https://ae-pic-a1.aliexpress-media.com/kf/S32dff424da2b489a81284d72851a0219Q.jpg',
      ],
      rating: 4.8,
      reviewsCount: 17900,
      productUrl: 'https://www.aliexpress.com/item/1005004732189021.html',
      badge: 'خيار المسافرين',
      badgeColor: Color(0xFF18A957),
      description:
          'حقيبة مثالية للعمل والجامعة والسفر، مزودة بقفل رقمي يحمي أجهزتك من السرقة، ومساحة مبطنة مخصصة لأجهزة الكمبيوتر المحمولة حتى 15.6 بوصة.',
      descriptionEn:
          'TSA-friendly lock, water-resistant oxford fabric, USB charging port, and padded laptop compartment.',
      features: [
        'قفل مدمج وسحابات خفية مضادة للسرقة',
        'منفذ USB خارجي لشحن الجوال أثناء التنقل',
        'قماش متين طارد للمياه مع بطانة مريحة للظهر',
      ],
    ),

    // 10. Alibaba - Wholesale TWS Earbuds
    GlobalShowcaseProduct(
      id: 'ali_baba_earbuds',
      name: 'سماعات بلوتوث TWS رقمية LED للتجار (عرض تسعير عينات وبالجملة)',
      nameEn: 'Wholesale TWS LED Wireless Earbuds with Charging Case',
      store: 'Alibaba',
      category: 'إلكترونيات',
      categoryEn: 'Electronics',
      priceUsd: 4.50,
      originalPriceUsd: 7.00,
      imageUrl: 'https://s.alicdn.com/@sc04/kf/H71343716a4d14b439c3e21ea5c43d9bfy.jpg',
      galleryImages: [
        'https://s.alicdn.com/@sc04/kf/H71343716a4d14b439c3e21ea5c43d9bfy.jpg',
      ],
      rating: 4.9,
      reviewsCount: 5800,
      productUrl: 'https://www.alibaba.com/product-detail/Wholesale-Tws-Earbuds_1600892019231.html',
      badge: 'للبيع بالجملة',
      badgeColor: Color(0xFF6852C8),
      description:
          'منتج تجاري مخصص للمتاجر والمستوردين، نوفر لك إمكانية طلب عينات فردية أو شحنات تجارية بأسعار الجملة المباشرة من المصنع.',
      descriptionEn:
          'High demand wholesale electronics with custom packaging and factory-direct pricing negotiated by Alline.',
      features: [
        'أسعار تنافسية تبدأ من كميات قليلة للتجار',
        'شاشة رقمية لمعرفة مستوى بطارية السماعات بدقة',
        'فريق Alline يتولى الفحص والتفاوض والشحن الجمركي',
      ],
    ),
  ];
}
