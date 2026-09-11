import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';

class CategoryAssetHelper {
  static const String _folder = 'assets/images/Categoires';

  static const String clothing = '$_folder/a2359c40-b8e1-4d16-8142-fb36ff4ddb8e.jpg';
  static const String cleaners = '$_folder/istockphoto-2169450161-612x612.jpg';
  static const String electronics = '$_folder/istockphoto-934679404-612x612.jpg';
  static const String furniture = '$_folder/pexels-artbovich-8082211.jpg';
  static const String cosmetics = '$_folder/pexels-bule-2127348686-34689878.jpg';
  static const String supermarket = '$_folder/pexels-eduschadesoares-5498233.jpg';
  static const String lighting = '$_folder/pexels-esther-234072-746496.jpg';
  static const String schoolOffice = '$_folder/pexels-giovanna-kamimura-399616174-30663291.jpg';
  static const String carAccessories = '$_folder/pexels-hilal-diken-2153971208-38712727.jpg';
  static const String perfumes = '$_folder/pexels-ivandesignx-29611647.jpg';
  static const String appliances = '$_folder/pexels-jaycee300s-3059779-18071814.jpg';
  static const String sports = '$_folder/pexels-jdgromov-4716814.jpg';
  static const String personalCare = '$_folder/pexels-karola-g-4202924.jpg';
  static const String baby = '$_folder/pexels-olia-danilevich-6213645.jpg';
  static const String kitchen = '$_folder/pexels-pnw-prod-8251820.jpg';
  static const String giftsOffers = '$_folder/pexels-shkrabaanthony-6187610.jpg';
  static const String healthCare = '$_folder/pexels-thefullonmonet-28994644.jpg';

  /// Maps a category to its designated primary asset image
  static String? getAssetForCategory({int? id, String? name, String? slug}) {
    // 1. Direct ID matching based on the store taxonomy
    switch (id) {
      case 1:
        return personalCare;
      case 2:
        return perfumes;
      case 3:
        return cosmetics;
      case 4:
        return kitchen;
      case 5:
        return cleaners;
      case 6:
        return appliances;
      case 7:
        return electronics;
      case 8:
        return healthCare;
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
        return kitchen; // Home maintenance / tools
      case 12117:
        return baby;
      case 12122:
        return kitchen; // Plastic & travel supplies
      case 12124:
        return sports;
      case 12137:
        return supermarket;
    }

    // 2. Keyword matching on name & slug for dynamic or newly added categories
    final text = '${name ?? ''} ${slug ?? ''}'.toLowerCase();

    if (text.contains('عطر') || text.contains('عطور') || text.contains('perfume')) {
      return perfumes;
    }
    if (text.contains('ملابس') || text.contains('ازياء') || text.contains('أزياء') || text.contains('cloth') || text.contains('fashion')) {
      return clothing;
    }
    if (text.contains('سوبر') || text.contains('بقالة') || text.contains('تموين') || text.contains('supermarket') || text.contains('grocery')) {
      return supermarket;
    }
    if (text.contains('مكياج') || text.contains('مستحضر') || text.contains('تجميل') || text.contains('cosmetic') || text.contains('makeup')) {
      return cosmetics;
    }
    if (text.contains('تنظيف') || text.contains('منظف') || text.contains('clean')) {
      return cleaners;
    }
    if (text.contains('إلكترون') || text.contains('الكترون') || text.contains('جوال') || text.contains('هاتف') || text.contains('سماعة') || text.contains('electronic') || text.contains('tech')) {
      return electronics;
    }
    if (text.contains('أثاث') || text.contains('اثاث') || text.contains('ديكور') || text.contains('furniture') || text.contains('decor')) {
      return furniture;
    }
    if (text.contains('طفل') || text.contains('أطفال') || text.contains('اطفال') || text.contains('رضيع') || text.contains('baby') || text.contains('kid')) {
      return baby;
    }
    if (text.contains('رياض') || text.contains('لياقة') || text.contains('جيم') || text.contains('sport') || text.contains('fitness')) {
      return sports;
    }
    if (text.contains('سيار') || text.contains('مركبة') || text.contains('car') || text.contains('auto')) {
      return carAccessories;
    }
    if (text.contains('مطبخ') || text.contains('بيت') || text.contains('منزل') || text.contains('أواني') || text.contains('kitchen') || text.contains('home')) {
      return kitchen;
    }
    if (text.contains('جهاز') || text.contains('أجهزة') || text.contains('اجهزة') || text.contains('appliance')) {
      return appliances;
    }
    if (text.contains('إضاءة') || text.contains('اضاءة') || text.contains('كهرباء') || text.contains('light')) {
      return lighting;
    }
    if (text.contains('مكتب') || text.contains('دراس') || text.contains('قرطاس') || text.contains('school') || text.contains('office')) {
      return schoolOffice;
    }
    if (text.contains('صحة') || text.contains('عناية') || text.contains('health') || text.contains('care')) {
      return healthCare;
    }
    if (text.contains('هدية') || text.contains('هدايا') || text.contains('عرض') || text.contains('عروض') || text.contains('gift') || text.contains('offer')) {
      return giftsOffers;
    }

    return null;
  }

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
                child: Icon(Icons.category_rounded, size: size * 0.45, color: const Color(0xFF94A3B8)),
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
        supermarket,
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
}
