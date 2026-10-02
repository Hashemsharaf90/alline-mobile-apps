import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_delivery_boy/features/chat/domain/services/chat_service_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_swipe_action.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_primary_button.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_text_field_widget.dart';
import 'package:sixvalley_delivery_boy/features/auth/domain/models/response_model.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/features/profile/domain/models/userinfo_model.dart';
import 'package:sixvalley_delivery_boy/features/profile/domain/services/profile_service_interface.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/home/widgets/alline_active_delivery_card.dart';
import 'package:sixvalley_delivery_boy/features/order/widgets/alline_order_history_item_widget.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_delivered_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_welcome_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_pending_approval_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_rejected_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_suspended_screen.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/controllers/driver_onboarding_controller.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/domain/services/driver_onboarding_service_interface.dart';
import 'package:sixvalley_delivery_boy/helper/delivery_destination.dart';
import 'package:sixvalley_delivery_boy/helper/driver_journey.dart';
import 'package:sixvalley_delivery_boy/helper/financial_input.dart';
import 'package:sixvalley_delivery_boy/theme/light_theme.dart';
import 'package:sixvalley_delivery_boy/theme/dark_theme.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_typography.dart';

class _ProfileService implements ProfileServiceInterface {
  UserInfoModel? profile = UserInfoModel(isActive: 1, isOnline: 1);
  final pending = Completer<ResponseModel>();
  int calls = 0;
  @override Future<dynamic> getProfileInfo() async => profile;
  @override Future<dynamic> profileStatusOnnOff(int status) { calls++; return pending.future; }
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class _OnboardingService implements DriverOnboardingServiceInterface {
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingChatService implements ChatServiceInterface {
  @override
  Future<dynamic> sendMessage(String message, int userId, List<XFile> files, List<PlatformFile>? platformFile) async => throw StateError('local failure');
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
void main() {
  test('Chat transport exception releases pending and allows retry', () async {
    final controller = ChatController(chatServiceInterFace: _FailingChatService());
    expect((await controller.sendMessage('message', 1)).isSuccess, isFalse);
    expect(controller.isSending, isFalse);
    expect((await controller.sendMessage('message', 1)).isSuccess, isFalse);
    expect(controller.isSending, isFalse);
  });
  setUp(() { Get.testMode = true; });
  tearDown(() { Get.reset(); });
  test('Arabic and English finance input rejects invalid and excessive values', () {
    expect(FinancialInput.amount('١٢٫٥'), 12.5);
    expect(FinancialInput.canWithdraw('12.5', 12.5), isTrue);
    for (final value in ['NaN', 'Infinity', '-1', '0', 'text', '13']) {
      expect(FinancialInput.canWithdraw(value, 12.5), isFalse);
    }
    expect(FinancialInput.canWithdraw('1', null), isFalse);
    expect(FinancialInput.maskAccount('123456789'), '•••• 6789');
    expect(FinancialInput.maskAccount('123'), '••••');
  });
  test('Missing store never resolves to customer; zero latitude is valid', () {
    final order = OrderModel(driverJourneyStatus: 'accepted', shippingAddress: ShippingAddress(latitude: '12', longitude: '44'));
    expect(DeliveryDestination.coordinates(order), isNull);
    order.driverJourneyStatus = 'picked_up';
    expect(DeliveryDestination.coordinates(order)?.latitude, 12);
    order.shippingAddress = ShippingAddress(latitude: '0', longitude: '44');
    expect(DeliveryDestination.coordinates(order)?.latitude, 0);
    order.shippingAddress = ShippingAddress(latitude: '91', longitude: '44');
    expect(DeliveryDestination.coordinates(order), isNull);
  });
  test('Terminal core state overrides stale journey and unknown state is localized', () {
    expect(DriverJourney.status(OrderModel(orderStatus: 'canceled', driverJourneyStatus: 'accepted')), 'canceled');
    expect(DriverJourney.labelKey('internal_unknown'), 'alline_status_unavailable');
    for (final status in DriverJourney.stages) {
      expect(DriverJourney.labelKey(status), 'status_$status');
    }
  });
  test('Light and dark typography use the bundled Alline family', () {
    for (final theme in [light, dark]) {
      expect(theme.textTheme.bodyLarge?.fontFamily, AllineTypography.fontFamily);
      expect(theme.textTheme.titleLarge?.height, greaterThanOrEqualTo(1.4));
      expect(theme.colorScheme.surface, isNot(theme.colorScheme.onSurface));
    }
  });
  testWidgets('Offline API refusal retains online state and blocks duplicate requests', (tester) async {
    final service = _ProfileService();
    final controller = ProfileController(profileServiceInterface: service);
    await controller.getProfile();
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => TextButton(
      onPressed: () => controller.profileStatusChange(context, 0), child: const Text('toggle')))));
    await tester.tap(find.text('toggle'));
    await tester.tap(find.text('toggle'));
    expect(service.calls, 1);
    expect(controller.profileModel?.isOnline, 1);
    service.pending.complete(ResponseModel(false, 'refused'));
    await tester.pump();
    expect(controller.profileModel?.isOnline, 1);
    expect(controller.isStatusChanging, isFalse);
  });
  test('Failed profile refresh retains confirmed cache', () async {
    final service = _ProfileService();
    final controller = ProfileController(profileServiceInterface: service);
    await controller.getProfile();
    final previous = controller.profileModel;
    service.profile = null;
    await controller.getProfile();
    expect(controller.profileModel, same(previous));
    expect(controller.profileLoadFailed, isTrue);
  });
  for (final direction in TextDirection.values) {
    testWidgets('Swipe ${direction.name} waits for API, resets on refusal, prevents duplicate', (tester) async {
      final result = Completer<bool>();
      var calls = 0;
      await tester.pumpWidget(MaterialApp(home: Directionality(textDirection: direction, child: Scaffold(body: AllineSwipeAction(
        label: 'تأكيد الوصول إلى وجهة التوصيل', onSwipe: () { calls++; return result.future; })))));
      await tester.drag(find.byType(IconButton), Offset(direction == TextDirection.rtl ? -700 : 700, 0));
      await tester.pump();
      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      result.complete(false);
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.byType(IconButton), findsOneWidget);
    });
  }
  testWidgets('Swipe does not confirm thrown errors or disabled action', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AllineSwipeAction(label: 'confirm', onSwipe: () async => throw StateError('network')))));
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AllineSwipeAction(label: 'disabled', enabled: false, onSwipe: () async => true))));
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });

  for (final darkMode in [false, true]) {
    for (final direction in TextDirection.values) {
      for (final size in [const Size(320, 640), const Size(430, 932)]) {
        testWidgets('Core cards ${darkMode ? 'dark' : 'light'} ${direction.name} ${size.width} scale 1.5', (tester) async {
          tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
          Get.addTranslations({'ar': Map<String,String>.from(jsonDecode(File('assets/language/ar.json').readAsStringSync())), 'en': Map<String,String>.from(jsonDecode(File('assets/language/en.json').readAsStringSync()))});
          final order = OrderModel(id: 1, driverJourneyStatus: 'heading_to_store', orderStatus: 'processing', isGuest: true, isPause: false);
          await tester.pumpWidget(GetMaterialApp(theme: darkMode ? dark : light, locale: Locale(direction == TextDirection.rtl ? 'ar' : 'en'), home: MediaQuery(
            data: MediaQueryData(size: size, textScaler: const TextScaler.linear(1.5)), child: Directionality(textDirection: direction, child: Scaffold(body: SingleChildScrollView(child: Column(children: [
              AllineActiveDeliveryCard(order: order), AllineOrderHistoryItemWidget(order: order),
              AllinePrimaryButton(text: 'تأكيد استلام الطلب من المتجر والمتابعة إلى العميل', onPressed: () {}),
              CustomTextFieldWidget(hintText: 'phone', inputType: TextInputType.phone),
              AllineSwipeAction(label: 'تأكيد الوصول إلى موقع العميل وإتمام إجراءات التسليم', onSwipe: () async => false),
            ])))))));
          await tester.pump();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  final screens = <String,Widget>{
    'welcome': const DriverWelcomeScreen(), 'pending': const DriverPendingApprovalScreen(),
    'rejected': const DriverRejectedScreen(reviewNote: 'ملاحظة مراجعة طويلة للتحقق من وضوح النص العربي وإمكانية تكبيره'),
    'suspended': const DriverSuspendedScreen(reviewNote: 'ملاحظة مراجعة الحساب'),
    'delivered': const OrderDeliveredScreen(orderID: 'QA'),
  };
  for (final entry in screens.entries) {
    for (final darkMode in [false,true]) {
      testWidgets('Rendered ${entry.key} ${darkMode ? 'dark' : 'light'} Arabic small screen', (tester) async {
        tester.view.physicalSize = const Size(320,640); tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        final font = FontLoader(AllineTypography.fontFamily)..addFont(rootBundle.load('assets/fonts/tajawal/Tajawal-Regular.ttf'))..addFont(rootBundle.load('assets/fonts/tajawal/Tajawal-Bold.ttf'));
        await font.load();
        await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
        Get.addTranslations({'ar':Map<String,String>.from(jsonDecode(File('assets/language/ar.json').readAsStringSync()))});
        Get.put(DriverOnboardingController(onboardingService:_OnboardingService()));
        await tester.pumpWidget(GetMaterialApp(theme:darkMode?dark:light,locale:const Locale('ar'),home:MediaQuery(data:const MediaQueryData(size:Size(320,640),textScaler:TextScaler.linear(1.5)),child:Directionality(textDirection:TextDirection.rtl,child:entry.value))));
        await tester.pumpAndSettle();
        if (entry.key == 'welcome') {
          await tester.runAsync(() => precacheImage(const AssetImage(Images.logo), tester.element(find.byType(Scaffold))));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/${entry.key}_${darkMode?'dark':'light'}_rtl.png'));
      });
    }
  }
}
