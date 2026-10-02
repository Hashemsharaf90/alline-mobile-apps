import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/onboarding/widgets/alline_welcome_view.dart';

void main() {
  testWidgets(
      'Welcome fits narrow screens and exposes all actions in both languages',
      (tester) async {
    final capture = Platform.environment['WELCOME_CAPTURE'];
    final key = GlobalKey();
    var registers = 0, logins = 0, guests = 0, languages = 0;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      try {
        await (FontLoader('AllineTajawal')
              ..addFont(
                  rootBundle.load('assets/fonts/tajawal/Tajawal-Regular.ttf'))
              ..addFont(
                  rootBundle.load('assets/fonts/tajawal/Tajawal-Bold.ttf')))
            .load();
      } catch (_) {}
      try {
        await (FontLoader('MaterialIcons')
              ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
            .load();
      } catch (_) {}
    });
    for (final scenario in [
      (size: const Size(390, 844), ar: true, scale: 1.0),
      (size: const Size(320, 568), ar: true, scale: 1.5),
      (size: const Size(390, 844), ar: false, scale: 1.0),
    ]) {
      tester.view.physicalSize = scenario.size;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: 'AllineTajawal'),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scenario.scale)),
            child: child!),
        home: RepaintBoundary(
            key: key,
            child: AllineWelcomeView(
              isArabic: scenario.ar,
              onRegister: () => registers++,
              onLogin: () => logins++,
              onGuest: () => guests++,
              onLanguage: () => languages++,
            )),
      ));
      await tester.runAsync(() async {
        final context = tester.element(find.byType(AllineWelcomeView));
        await precacheImage(
            const AssetImage(AllineWelcomeView.heroAsset), context);
        if (!context.mounted) return;
        await precacheImage(
            const AssetImage(AllineWelcomeView.logoAsset), context);
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (capture != null && scenario.ar && scenario.scale == 1) {
        debugDisableShadows = false;
        tester.element(find.byType(AllineWelcomeView)).markNeedsBuild();
        await tester.pump();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(capture).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        debugDisableShadows = true;
      }
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.ensureVisible(find.byType(OutlinedButton));
      await tester.tap(find.byType(OutlinedButton));
      await tester.ensureVisible(find.byType(TextButton).first);
      await tester.tap(find.byType(TextButton).first);
      await tester.ensureVisible(find.byType(TextButton).last);
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(registers, 3);
    expect(logins, 3);
    expect(guests, 3);
    expect(languages, 3);
  });
}
