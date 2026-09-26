import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/home_screens.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/seller_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/widgets/dashboard_menu_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_smart_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/domain/services/location_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LocationService implements LocationServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Products extends ProductController {
  _Products() : super(productServiceInterface: null);
  @override
  ProductModel get featuredProductModel => _model(1, 'مختار');
  @override
  ProductModel get latestProductModel => _model(21, 'حديث');
  @override
  ProductModel get homeBestSellingModel => _model(11, 'الأكثر مبيعًا');
  @override
  ProductModel get discountedProductModel => _model(31, 'عرض');

  ProductModel _model(int start, String label) => ProductModel(products: [
        for (var index = 0; index < 4; index++)
          Product(
            id: start + index,
            name: '$label ${index + 1} بعنوان عربي طويل لاختبار سطرين',
            unitPrice: 1500 + index * 1250,
            discount: label == 'عرض' ? 10 : 0,
            discountType: 'percent',
            currentStock: 4,
            productType: 'physical',
            slug: '$label-$index',
          ),
      ]);
}

class _Shops extends ShopController {
  _Shops() : super(shopServiceInterface: null);
  @override
  SellerModel get topSellerModel => SellerModel(sellers: [
        Seller(id: 1, averageRating: 4.7, shop: Shop(name: 'متجر تجريبي')),
        Seller(id: 2, averageRating: 0, shop: Shop(name: '????????')),
      ]);
}

void main() {
  testWidgets(
      'Home sections remain usable with RTL, narrow widths and larger text',
      (tester) async {
    final location = LocationController(
      locationServiceInterface: _LocationService(),
    );
    SharedPreferences.setMockInitialValues({
      'alline_delivery_latitude': 15.3694,
      'alline_delivery_longitude': 44.1910,
      'alline_delivery_label': 'C637+JRQ، صنعاء، حدة',
    });
    await location.restoreDeliveryLocation();
    final cart = CartController(cartServiceInterface: null);
    final captureKey = GlobalKey();
    final categories = CategoryController(categoryServiceInterface: null);
    categories.categoryList.addAll([
      CategoryModel(id: 7, name: 'الإلكترونيات'),
      CategoryModel(id: 2, name: 'العطور'),
      CategoryModel(id: 3, name: 'الجمال والعناية'),
      CategoryModel(id: 4, name: 'المنزل والمطبخ'),
    ]);
    final products = _Products();
    final shops = _Shops();
    final splash = SplashController(splashServiceInterface: null);
    final banners = BannerController(bannerServiceInterface: null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await (FontLoader('AllineTajawal')
            ..addFont(
                rootBundle.load('assets/fonts/tajawal/Tajawal-Regular.ttf'))
            ..addFont(rootBundle.load('assets/fonts/tajawal/Tajawal-Bold.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });

    Widget app(double scale, {bool dark = false}) => MultiProvider(
          providers: [
            ChangeNotifierProvider<LocationController>.value(value: location),
            ChangeNotifierProvider<CartController>.value(value: cart),
            ChangeNotifierProvider<CategoryController>.value(value: categories),
            ChangeNotifierProvider<ProductController>.value(value: products),
            ChangeNotifierProvider<ShopController>.value(value: shops),
            ChangeNotifierProvider<SplashController>.value(value: splash),
            ChangeNotifierProvider<BannerController>.value(value: banners),
          ],
          child: MaterialApp(
            theme: dark ? AllineTheme.dark : AllineTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: RepaintBoundary(
                key: captureKey,
                child: Scaffold(
                  backgroundColor:
                      dark ? const Color(0xFF0B1220) : Colors.white,
                  body: const HomePage(),
                  bottomNavigationBar: SafeArea(
                      top: false,
                      child: SizedBox(
                          height: 72 + (scale - 1) * 12,
                          child: Row(children: [
                            for (final name in [
                              'home',
                              'all_category',
                              'cart',
                              'orders',
                              'more'
                            ])
                              Expanded(
                                  child: CustomMenuWidget(
                                      isSelected: name == 'home',
                                      name: name,
                                      icon: '',
                                      showCartCount: name == 'cart',
                                      onTap: () {})),
                          ]))),
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(app(1));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(AllineSmartHeaderWidget));
      for (final asset in [
        'assets/images/alline/login_logo_transparent.png',
        Images.catElectronics,
        Images.catPerfumes,
        Images.catCosmetics,
        Images.catKitchenAccessories,
        Images.allineSupermarketHeroRealistic,
        'assets/images/alline/welcome_shopping_hero.png',
        Images.banner1,
      ]) {
        await precacheImage(AssetImage(asset), context);
      }
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ابحث عن منتج أو متجر...'), findsOneWidget);
    expect(find.text('السوق المحلي'), findsNothing);
    expect(find.text('السوبر ماركت'), findsOneWidget);
    expect(find.text('التسوق العالمي'), findsOneWidget);
    expect(find.text('صنعاء، حدة'), findsOneWidget);
    expect(find.textContaining('C637+JRQ'), findsNothing);
    expect(
        find.descendant(
          of: find.byType(AllineSmartHeaderWidget),
          matching: find.byIcon(Icons.shopping_cart_outlined),
        ),
        findsNothing);
    expect(
        find.descendant(
          of: find.byType(AllineSmartHeaderWidget),
          matching: find.byIcon(Icons.headset_mic_rounded),
        ),
        findsOneWidget);
    expect(find.text('تسوق من العالم'), findsOneWidget);
    expect(find.text('تسوق من السوبر ماركت'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final capture = Platform.environment['HOME_CAPTURE'];
    if (capture != null) {
      await tester.runAsync(() async {
        final image = await (captureKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(capture).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      tester.view.physicalSize = const Size(390, 2200);
      await tester.pumpWidget(app(1));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(() async {
        final image = await (captureKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1.5);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(capture.replaceFirst('.png', '_FULL.png'))
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      tester.view.physicalSize = const Size(390, 844);
    }

    await tester.pumpWidget(app(1, dark: true));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<Text>(find.text('العطور')).style?.color,
        const Color(0xFFF5F7FA));
    expect(tester.takeException(), isNull);
    if (capture != null) {
      await tester.runAsync(() async {
        final image = await (captureKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(capture.replaceFirst('.png', '_DARK.png'))
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpWidget(app(1.3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 11; i++) {
      await tester.drag(
          find.byType(CustomScrollView).first, const Offset(0, -340));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(AllineProductCard), findsWidgets);
    expect(find.text('جميع المنتجات'), findsNothing);
    expect(find.text('متجر Alline'), findsWidgets);
    expect(find.text('حسابي'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
