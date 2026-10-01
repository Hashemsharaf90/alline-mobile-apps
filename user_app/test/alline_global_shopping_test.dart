import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_showcase_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_hero_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_how_it_works_accordion.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_search_and_link_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_stores_grid.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_shopping_states.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

void main() {
  group('Global Shopping Unit & Widget Tests', () {
    test('Image asset constant is registered correctly', () {
      expect(
        Images.globalShoppingHeroBanner,
        equals('assets/images/alline/global_shopping_hero_banner.png'),
      );
    });

    test('Showcase repository contains required spotlight items', () {
      final products = GlobalShowcaseRepository.curatedProducts;
      expect(products.isNotEmpty, isTrue);

      final huawei = products.firstWhere((p) => p.id == 'huawei_band');
      expect(huawei.store, equals('Amazon'));
      expect(huawei.priceUsd, equals(49.99));

      final headphones = products.firstWhere((p) => p.id == 'wireless_headphones');
      expect(headphones.store, equals('AliExpress'));
      expect(headphones.priceUsd, equals(29.50));

      final coat = products.firstWhere((p) => p.id == 'shein_coat');
      expect(coat.store, equals('SHEIN'));
      expect(coat.priceUsd, equals(34.00));

      final tools = products.firstWhere((p) => p.id == 'alibaba_tools');
      expect(tools.store, equals('Alibaba'));
      expect(tools.isRfq, isTrue);
      expect(tools.moq, equals(20));
    });

    testWidgets('GlobalHeroBannerWidget renders and triggers onTap callback', (tester) async {
      bool bannerTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalHeroBannerWidget(
              onTap: () => bannerTapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(GlobalHeroBannerWidget), findsOneWidget);
      await tester.tap(find.byType(GlobalHeroBannerWidget));
      expect(bannerTapped, isTrue);
    });

    testWidgets('GlobalStoresGrid displays all 4 official stores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalStoresGrid(
              stores: const [],
              onStoreTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('متاجرك العالمية'), findsOneWidget);
      expect(find.text('علي بابا'), findsOneWidget);
      expect(find.text('أمازون'), findsOneWidget);
      expect(find.text('علي إكسبريس'), findsOneWidget);
      expect(find.text('شي إن'), findsOneWidget);
      expect(find.text('تصفّح المتجر'), findsNWidgets(4));
    });

    testWidgets('GlobalHowItWorksAccordion toggles expansion', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalHowItWorksAccordion(),
          ),
        ),
      );

      expect(find.text('كيف تتسوق عالمياً عبر Alline؟'), findsOneWidget);
      // Tap header to expand
      await tester.tap(find.text('كيف تتسوق عالمياً عبر Alline؟'));
      await tester.pumpAndSettle();

      expect(find.textContaining('اختر متجراً أو منتجاً:'), findsOneWidget);
      expect(find.textContaining('أضف الرابط:'), findsOneWidget);
      expect(find.textContaining('راجع التكلفة والطلب:'), findsOneWidget);
    });

    testWidgets('GlobalSearchAndLinkBar displays action button and search hint', (tester) async {
      final controller = TextEditingController();
      bool addLinkTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchAndLinkBar(
              searchController: controller,
              onSearchChanged: (_) {},
              onAddLinkTap: () => addLinkTapped = true,
              onClearSearch: () {},
            ),
          ),
        ),
      );

      expect(find.text('إضافة رابط منتج'), findsOneWidget);
      expect(find.text('ابحث في المنتجات المعروضة'), findsOneWidget);

      await tester.tap(find.text('إضافة رابط منتج'));
      expect(addLinkTapped, isTrue);
    });

    testWidgets('GlobalShoppingEmptyWidget renders and responds to taps', (tester) async {
      bool addTapped = false;
      bool browseTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalShoppingEmptyWidget(
              onAddLinkTap: () => addTapped = true,
              onBrowseStoresTap: () => browseTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('لا توجد منتجات معروضة حالياً'), findsOneWidget);
      expect(find.text('أضف رابط منتج'), findsOneWidget);
      expect(find.text('تصفّح المتاجر'), findsOneWidget);

      await tester.tap(find.text('أضف رابط منتج'));
      expect(addTapped, isTrue);

      await tester.tap(find.text('تصفّح المتاجر'));
      expect(browseTapped, isTrue);
    });

    testWidgets('GlobalShoppingErrorWidget renders and responds to retry tap', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalShoppingErrorWidget(
              onRetry: () => retryTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('تعذّر تحميل المنتجات'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retryTapped, isTrue);
    });
  });
}
