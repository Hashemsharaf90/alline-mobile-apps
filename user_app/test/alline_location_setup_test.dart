import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/domain/services/location_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:provider/provider.dart';

class _LocationService implements LocationServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Location setup renders Alline actions on mobile sizes',
      (tester) async {
    final controller = LocationController(
      locationServiceInterface: _LocationService(),
    );
    final captureKey = GlobalKey();
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

    Widget app(double scale) =>
        ChangeNotifierProvider<LocationController>.value(
          value: controller,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: RepaintBoundary(
              key: captureKey,
              child: const LocationSetupScreen(),
            ),
          ),
        );

    await tester.pumpWidget(app(1));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(LocationSetupScreen));
      await precacheImage(
        const AssetImage('assets/images/alline/login_logo_transparent.png'),
        context,
      );
    });
    await tester.pumpAndSettle();

    expect(find.text('حدد موقع التوصيل'), findsOneWidget);
    expect(find.text('استخدام موقعي الحالي'), findsOneWidget);
    expect(find.text('تحديد الموقع يدويًا'), findsOneWidget);
    expect(find.text('تخطي الآن'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final capture = Platform.environment['LOCATION_SETUP_CAPTURE'];
    if (capture != null) {
      await tester.runAsync(() async {
        final image = await (captureKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(capture).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpWidget(app(1.25));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('تخطي الآن'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
