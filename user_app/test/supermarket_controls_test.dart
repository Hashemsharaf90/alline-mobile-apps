import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/quick_add_to_cart_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_theme.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';

void main() {
  for (final width in [360.0, 430.0]) {
    for (final dark in [false, true]) {
      testWidgets('Grocery card width=$width dark=$dark enlarged Arabic',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final cart = CartController(cartServiceInterface: null);
        final splash = SplashController(splashServiceInterface: null);
        await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: cart),
              ChangeNotifierProvider.value(value: splash),
            ],
            child: MaterialApp(
              theme: dark ? AllineTheme.dark : AllineTheme.light,
              home: Builder(
                  builder: (context) => MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1.5)),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Scaffold(
                              body: SizedBox(
                            width: (width - 44) / 2,
                            height: 356,
                            child: AllineProductCard(
                              grocery: true,
                              product: Product(
                                  id: 1,
                                  name: 'حليب كامل الدسم طويل الأجل',
                                  productType: 'physical',
                                  currentStock: 5,
                                  unit: 'لتر',
                                  unitPrice: 100,
                                  discount: 10,
                                  discountType: 'percent'),
                            ),
                          )),
                        ),
                      )),
            )));
        expect(tester.takeException(), isNull);
        expect(find.text('أضف'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        cart.dispose();
        splash.dispose();
      });
      testWidgets('RTL add control width=$width dark=$dark enlarged text',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final cart = CartController(cartServiceInterface: null);
        final gate = Completer<void>();
        var calls = 0;
        await tester.pumpWidget(ChangeNotifierProvider.value(
          value: cart,
          child: MaterialApp(
            theme: dark ? AllineTheme.dark : AllineTheme.light,
            home: Builder(
                builder: (context) => MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: const TextScaler.linear(1.5)),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Scaffold(
                            body: Align(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            width: (width - 44) / 2,
                            child: QuickAddToCartWidget(
                              product: Product(
                                  id: 1,
                                  productType: 'physical',
                                  currentStock: 5),
                              onAdd: () async {
                                calls++;
                                await gate.future;
                              },
                            ),
                          ),
                        )),
                      ),
                    )),
          ),
        ));
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(QuickAddToCartWidget)).height,
            greaterThanOrEqualTo(44));
        await tester.tap(find.text('أضف'));
        await tester.pump();
        await tester.tap(find.byType(QuickAddToCartWidget));
        await tester.pump();
        expect(calls, 1);
        gate.complete();
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        cart.dispose();
      });
    }
  }
}
