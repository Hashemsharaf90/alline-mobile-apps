import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class CategoryAssetHelper {
  static const String _folder = 'assets/images/Categoires';

  // Arabic source assets. Matching these by category name keeps the visual
  // correct even when category IDs differ between server environments.
  static const Map<String, String> _arabicNamedAssets = {
    'اكسسوارات السيارات': '$_folder/اكسسوارات السيارات.png',
    'الاثاث والديكور': '$_folder/الاثاث والديكور.png',
    'الاجهزة المنزلية': '$_folder/الاجهزة المنزلية.png',
    'الاضاءة والكهربائيات': '$_folder/الاضاءة والكهربائيات.png',
    'الالكترونيات': '$_folder/الالكترونيات .png',
    'الرياضة واللياقة': '$_folder/الرياضة واللياقة.png',
    'الصحة والعناية': '$_folder/الصحة والعناي.png',
    'الصيانة المنزلية والعدد': '$_folder/الصيانة المنزلية والعدد.png',
    'العطور': '$_folder/العطور.png',
    'العناية بالاطفال': '$_folder/العناية بالاطفال.png',
    'المستلزمات المدرسية والمكتبية':
        '$_folder/المستلزمات المدرسية والمكتبية.png',
    'الملابس والاكسسوارات': '$_folder/الملابس والاكسسوارات.jpg',
    'المنظفات المنزلية': '$_folder/المنظفات المنزلية.png',
    'الهدايا والعروض': '$_folder/الهدايا والعروض.png',
    'مستحضرات التجميل': '$_folder/مستحضرات التجميل.png',
    'مستلزمات البيت والمطبخ': '$_folder/مستلزمات البيت والمطبخ.png',
  };

  // 13 Primary Professional Category Assets (from assets/images/Categoires)
  static const String kitchenAccessories = Images.catKitchenAccessories;
  static const String carAccessories = Images.catCarAccessories;
  static const String furniture = Images.catFurnitureDecor;
  static const String appliances = Images.catHomeAppliances;
  static const String lighting = Images.catLightingElectrical;
  static const String electronics = Images.catElectronics;
  static const String sports = Images.catSportsFitness;
  static const String healthPersonalCare = Images.catHealthPersonalCare;
  static const String homeMaintenance = Images.catHomeMaintenance;
  static const String perfumes = Images.catPerfumes;
  static const String baby = Images.catBabyCare;
  static const String schoolOffice = Images.catSchoolOffice;
  static const String cosmetics = Images.catCosmetics;

  // Realistic HD Supermarket Assets (from assets/images/alline)
  static const String supermarket = Images.catSupermarketHd;
  static const String fruitsVeg = Images.catFruitsVegHd;
  static const String meat = Images.catMeatHd;
  static const String bakery = Images.catBakeryHd;
  static const String dairy = Images.catDairyHd;
  static const String restaurants = Images.catRestaurantsHd;

  // Fallbacks
  static const String personalCare = Images.catHealthPersonalCare;
  static const String kitchen = Images.catKitchenAccessories;
  static const String clothing =
      '$_folder/a2359c40-b8e1-4d16-8142-fb36ff4ddb8e.jpg';
  static const String cleaners = Images.catHomeMaintenance;
  static const String healthCare = Images.catHealthPersonalCare;
  static const String giftsOffers = Images.catPerfumes;
  static const String general = Images.category;

  /// Maps a category to its designated primary asset image
  static String? getAssetForCategory({int? id, String? name, String? slug}) {
    // 1. Prefer semantic name matching so every Arabic-named image is paired
    // with the category carrying the same name, regardless of its server ID.
    final normalizedName = _normalizeArabic(name ?? '');
    for (final entry in _arabicNamedAssets.entries) {
      final normalizedKey = _normalizeArabic(entry.key);
      if (normalizedName == normalizedKey ||
          normalizedName.contains(normalizedKey)) {
        return entry.value;
      }
    }

    // 2. Direct ID matching based on the current store taxonomy.
    switch (id) {
      case 1:
        return healthPersonalCare;
      case 2:
        return perfumes;
      case 3:
        return cosmetics;
      case 4:
        return kitchenAccessories;
      case 5:
        return homeMaintenance;
      case 6:
        return appliances;
      case 7:
        return electronics;
      case 8:
        return healthPersonalCare;
      case 9:
        return clothing;
      case 10:
        return giftsOffers;
      case 11:
        return carAccessories;
      case 12:
        return furniture;
      case 12043:
        return schoolOffice;
      case 12083:
        return lighting;
      case 12099:
        return kitchenAccessories;
      case 12117:
        return baby;
      case 12122:
        return kitchenAccessories;
      case 12124:
        return sports;
      case 12137:
        return supermarket;
    }

    // 3. Keyword matching on name & slug for dynamic or newly added categories
    final text = '${name ?? ''} ${slug ?? ''}'.toLowerCase();

    // 1. اكسسوارات البيت والمطبخ
    if (text.contains('مطبخ') ||
        text.contains('بيت') ||
        text.contains('منزل') ||
        text.contains('أواني') ||
        text.contains('اواني') ||
        text.contains('طهي') ||
        text.contains('أدوات منزلية') ||
        text.contains('ادوات منزلية') ||
        text.contains('kitchen') ||
        text.contains('cook') ||
        text.contains('home accessories') ||
        text.contains('houseware')) {
      return kitchenAccessories;
    }

    // 2. اكسسوارات السيارات
    if (text.contains('سيار') ||
        text.contains('سيارات') ||
        text.contains('مركبة') ||
        text.contains('car') ||
        text.contains('auto') ||
        text.contains('vehicle')) {
      return carAccessories;
    }

    // 3. الاثاث والديكور
    if (text.contains('أثاث') ||
        text.contains('اثاث') ||
        text.contains('ديكور') ||
        text.contains('مفروشات') ||
        text.contains('furniture') ||
        text.contains('decor')) {
      return furniture;
    }

    // 4. الاجهزة المنزلية
    if (text.contains('أجهزة منزلية') ||
        text.contains('اجهزة منزلية') ||
        text.contains('أجهزة') ||
        text.contains('اجهزة') ||
        text.contains('غسال') ||
        text.contains('ثلاج') ||
        text.contains('مكوا') ||
        text.contains('مكنس') ||
        text.contains('ميكرويف') ||
        text.contains('appliance')) {
      return appliances;
    }

    // 5. الاضاءة والكهربائيات
    if (text.contains('إضاءة') ||
        text.contains('اضاءة') ||
        text.contains('كهرباء') ||
        text.contains('كهربائ') ||
        text.contains('لمب') ||
        text.contains('إنارة') ||
        text.contains('light') ||
        text.contains('lamp') ||
        text.contains('electrical')) {
      return lighting;
    }

    // 6. الالكترونيات
    if (text.contains('إلكترون') ||
        text.contains('الكترون') ||
        text.contains('جوال') ||
        text.contains('هاتف') ||
        text.contains('شاحن') ||
        text.contains('سماعة') ||
        text.contains('كمبيوتر') ||
        text.contains('لابتوب') ||
        text.contains('تابلت') ||
        text.contains('electronic') ||
        text.contains('phone') ||
        text.contains('mobile') ||
        text.contains('tech')) {
      return electronics;
    }

    // 7. الرياضة واللياقة
    if (text.contains('رياض') ||
        text.contains('لياقة') ||
        text.contains('جيم') ||
        text.contains('تمارين') ||
        text.contains('بدني') ||
        text.contains('sport') ||
        text.contains('fitness') ||
        text.contains('gym')) {
      return sports;
    }

    // 8. الصحة والعناية الشخصية
    if (text.contains('صحة') ||
        text.contains('عناية شخصية') ||
        text.contains('عناية بالبشرة') ||
        text.contains('شعر') ||
        text.contains('شامبو') ||
        text.contains('غسول') ||
        text.contains('فيتامين') ||
        text.contains('طبي') ||
        text.contains('صيدل') ||
        text.contains('health') ||
        text.contains('personal') ||
        text.contains('care') ||
        text.contains('pharmacy') ||
        text.contains('wellness')) {
      return healthPersonalCare;
    }

    // 9. الصيانة المنزلية والعدد
    if (text.contains('صيانة') ||
        text.contains('عدد') ||
        text.contains('أدوات') ||
        text.contains('ادوات') ||
        text.contains('تصليح') ||
        text.contains('ورشة') ||
        text.contains('مفك') ||
        text.contains('صيانة منزلية') ||
        text.contains('tools') ||
        text.contains('maintenance') ||
        text.contains('repair') ||
        text.contains('hardware')) {
      return homeMaintenance;
    }

    // 10. العطور
    if (text.contains('عطر') ||
        text.contains('عطور') ||
        text.contains('بخور') ||
        text.contains('عود') ||
        text.contains('مسك') ||
        text.contains('perfume') ||
        text.contains('fragrance') ||
        text.contains('scent')) {
      return perfumes;
    }

    // 11. العناية بالاطفال
    if (text.contains('طفل') ||
        text.contains('أطفال') ||
        text.contains('اطفال') ||
        text.contains('رضيع') ||
        text.contains('حفاض') ||
        text.contains('مواليد') ||
        text.contains('baby') ||
        text.contains('kid') ||
        text.contains('infant') ||
        text.contains('toddler')) {
      return baby;
    }

    // 12. المستلزمات المدرسية والمكتبية
    if (text.contains('مكتب') ||
        text.contains('مكتبي') ||
        text.contains('دراس') ||
        text.contains('مدرس') ||
        text.contains('قرطاس') ||
        text.contains('قرطاسية') ||
        text.contains('دفاتر') ||
        text.contains('أقلام') ||
        text.contains('اقلام') ||
        text.contains('school') ||
        text.contains('office') ||
        text.contains('stationery')) {
      return schoolOffice;
    }

    // 13. مستحضرات التجميل
    if (text.contains('مكياج') ||
        text.contains('مستحضر') ||
        text.contains('تجميل') ||
        text.contains('ميك اب') ||
        text.contains('روج') ||
        text.contains('cosmetic') ||
        text.contains('makeup') ||
        text.contains('beauty')) {
      return cosmetics;
    }

    // Supermarket & Fresh Foods
    if (text.contains('خضار') ||
        text.contains('فواك') ||
        text.contains('ثمار') ||
        text.contains('طازج') ||
        text.contains('veg') ||
        text.contains('fruit')) {
      return fruitsVeg;
    }
    if (text.contains('لحم') ||
        text.contains('لحوم') ||
        text.contains('دجاج') ||
        text.contains('دواجن') ||
        text.contains('meat') ||
        text.contains('poultry') ||
        text.contains('butcher')) {
      return meat;
    }
    if (text.contains('مخبز') ||
        text.contains('مخابز') ||
        text.contains('خبز') ||
        text.contains('معجنات') ||
        text.contains('حلويات') ||
        text.contains('حلى') ||
        text.contains('كيك') ||
        text.contains('bakery') ||
        text.contains('bread') ||
        text.contains('sweet')) {
      return bakery;
    }
    if (text.contains('ألبان') ||
        text.contains('البان') ||
        text.contains('حليب') ||
        text.contains('أجبان') ||
        text.contains('اجبان') ||
        text.contains('جبن') ||
        text.contains('زبادي') ||
        text.contains('بيض') ||
        text.contains('dairy') ||
        text.contains('milk') ||
        text.contains('cheese')) {
      return dairy;
    }
    if (text.contains('مطعم') ||
        text.contains('مطاعم') ||
        text.contains('وجب') ||
        text.contains('أكل') ||
        text.contains('برجر') ||
        text.contains('بيتزا') ||
        text.contains('restaurant') ||
        text.contains('food') ||
        text.contains('meal')) {
      return restaurants;
    }
    if (text.contains('سوبر') ||
        text.contains('بقالة') ||
        text.contains('تموين') ||
        text.contains('غذائ') ||
        text.contains('supermarket') ||
        text.contains('grocery') ||
        text.contains('market')) {
      return supermarket;
    }

    // Apparel
    if (text.contains('ملابس') ||
        text.contains('ازياء') ||
        text.contains('أزياء') ||
        text.contains('رجالي') ||
        text.contains('نسائي') ||
        text.contains('cloth') ||
        text.contains('fashion')) {
      return clothing;
    }

    return null;
  }

  static String _normalizeArabic(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Builds a circular avatar widget for a category
  static Widget buildCircularCategoryAvatar({
    required CategoryModel? category,
    double size = 66,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    final asset = getAssetForCategory(
      id: category?.id,
      name: category?.name,
      slug: category?.slug,
    );

    final remoteUrl = category?.imageFullUrl?.path;
    final bool hasValidRemote = remoteUrl != null &&
        remoteUrl.isNotEmpty &&
        !remoteUrl.contains('placeholder');

    Widget imageWidget;
    if (asset != null) {
      // Primary custom asset image
      imageWidget = Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 2.5).toInt(),
        cacheHeight: (size * 2.5).toInt(),
        errorBuilder: (_, __, ___) => hasValidRemote
            ? CustomImageWidget(
                image: remoteUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Container(
                width: size,
                height: size,
                color: const Color(0xFFE2E8F0),
                child: Icon(Icons.category_rounded,
                    size: size * 0.45, color: const Color(0xFF94A3B8)),
              ),
      );
    } else if (hasValidRemote) {
      imageWidget = CustomImageWidget(
        image: remoteUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        general,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 2.5).toInt(),
        cacheHeight: (size * 2.5).toInt(),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: imageWidget,
      ),
    );
  }

  /// Compact home artwork: keeps transparent/3D assets fully visible instead
  /// of cropping them as photography.
  static Widget buildContainedCategoryArtwork({
    required CategoryModel? category,
    double size = 58,
  }) {
    final asset = getAssetForCategory(
      id: category?.id,
      name: category?.name,
      slug: category?.slug,
    );
    final remoteUrl = category?.imageFullUrl?.path;
    final hasRemote = remoteUrl != null &&
        remoteUrl.isNotEmpty &&
        !remoteUrl.contains('placeholder');

    if (asset != null) {
      return Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        cacheWidth: (size * 3).toInt(),
        cacheHeight: (size * 3).toInt(),
        errorBuilder: (_, __, ___) => _categoryFallback(size),
      );
    }
    if (hasRemote) {
      return CustomImageWidget(
        image: remoteUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return _categoryFallback(size);
  }

  static Widget _categoryFallback(double size) => Icon(
        Icons.category_rounded,
        size: size * .48,
        color: const Color(0xFF6D85AF),
      );
}
