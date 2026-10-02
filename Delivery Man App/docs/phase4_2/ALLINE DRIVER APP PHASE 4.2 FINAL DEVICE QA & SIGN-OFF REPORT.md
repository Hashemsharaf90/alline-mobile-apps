# ALLINE DRIVER APP
## PHASE 4.2 FINAL DEVICE QA & SIGN-OFF REPORT

التاريخ: 2026-10-02. التطبيق: D:\6Valley\apps\Delivery Man App. Backend: C:\wamp64\www\6valley. API المحلي: http://127.0.0.1:8000.

## Executive Summary

**PHASE 4.2 PARTIAL.** اتصل جهاز Samsung SM-S918W، وثُبت التطبيق وشُغّل. نجح تسجيل الدخول على الجهاز وظهرت لوحة السائق بحالة Online؛ خادم API المحلي متاح عبر ADB reverse. واجهة الطلبات وAPI الحاليان يعيدان صفر طلبات، لذلك تعذر اختبار رحلة التوصيل كاملة.

## Local safety and API

Wamp Apache/MariaDB/MySQL كانت Running عند الفحص. عنوان التطبيق local QA هو 127.0.0.1:8000 مع ALLINE_LOCAL_QA=true. login محلي مصرح أعاد active؛ profile أكد is_active=1/is_online=1. واجهات القراءة المفحوصة HTTP 200، بما فيها config/profile/current/history/notifications/onboarding/chat/reviews/emergency/earnings/deposits وقوائم السحب الصحيحة. لا طلبات حالية أو تاريخية. لم ترسل رسالة/سحب/تغيير حالة. لا تعديل يدوي لقاعدة البيانات، لا تغييرات Backend أو Customer/Seller أو migrations.

## Device and APK

Samsung SM-S918W، Android 15/API 35، متصل ومصرح عبر ADB. تثبيت التطبيق 1.0.2 (versionCode 3) نجح، وMainActivity في المقدمة. ADB reverse tcp:8000 يعمل.

APK: D:\6Valley\apps\Delivery Man App\build\app\outputs\flutter-apk\app-debug.apk
SHA256: c71217f7a65ae45ba228431e30100b4566242cf5b3ed90cf42273fd2fd59ca39
الحجم: 126819780 bytes. بناء local QA debug، لا يعني نجاح الإقلاع.

## Regression

flutter analyze --no-pub: No issues found (exit 0). flutter test --no-pub: 40 passed, 0 failed, 0 skipped. local QA APK build: PASS.

## 83-item device checklist

حالات الفحص: PASS / FAIL / BLOCKED / PARTIAL / NOT EXECUTED. مصفوفة 44 شاشة مرفقة في ../phase4_1/screen-matrix.csv.

### 1. Executive Summary

**PARTIAL** — Device connected later in this pass; install and brief launch are recorded below. Full QA remains partial because focus changed to another app and no test order exists.

### 2. Device Information

**PARTIAL** — Last known before this pass: Samsung SM-S918W, Android 15/API35. Not currently attached.

### 3. ADB Status

**PASS** — ADB reports one authorized Samsung SM-S918W device running Android 15/API 35; reverse tcp:8000 is configured.

### 4. APK Install

**PASS** — adb install -r completed successfully for the local QA APK. Package version 1.0.2 (versionCode 3).

### 5. App Boot

**PASS** — التطبيق بقي في المقدمة بعد التشغيل، واجتاز شاشة الدخول إلى لوحة السائق. لا FATAL EXCEPTION/FlutterError في سجل الفحص المحدود.

### 6. Local API Connectivity

**PASS** — ADB reverse tcp:8000 مهيأ؛ تسجيل الدخول من واجهة الجهاز نجح، وحُمّلت لوحة السائق من API المحلي.

### 7. Test Driver

**PASS** — تسجيل الدخول من واجهة التطبيق نجح؛ ظهرت لوحة السائق والحساب بحالة Online.

### 8. Test Order

**BLOCKED** — واجهة الطلبات وAPI يعيدان قائمة فارغة؛ لا يوجد test order ID.

### 9. Assignment

**BLOCKED** — No local order created/assigned; no direct DB writes.

### 10. Assigned

**BLOCKED** — No assigned test order.

### 11. Accepted

**BLOCKED** — Widget coverage only; no live transition.

### 12. Heading To Store

**BLOCKED** — No accepted transition was sent.

### 13. Store Map

**BLOCKED** — No assigned order/store location to check.

### 14. Arrived Store

**BLOCKED** — No real-device Maps check.

### 15. Pickup

**PARTIAL** — Unit tests cover missing store destination and coordinate validation; no device map.

### 16. Core Status Sync

**BLOCKED** — No store-arrival transition.

### 17. Heading Customer

**BLOCKED** — No pickup/core-status synchronization against a real order.

### 18. Customer Map

**PARTIAL** — Destination choice is unit-tested; real customer data/map not checked.

### 19. Background Tracking

**BLOCKED** — No heading-to-customer transition.

### 20. Offline Tracking

**BLOCKED** — Needs active order and device.

### 21. Arrived Customer

**BLOCKED** — No real location points/backend record check.

### 22. COD

**BLOCKED** — No background/resume test.

### 23. OTP

**BLOCKED** — No offline tracking test.

### 24. POD

**BLOCKED** — No customer-arrival transition.

### 25. Delivery

**PARTIAL** — General config read only; order-specific verification mode unknown.

### 26. Double Submission

**BLOCKED** — No COD collection.

### 27. Tracking Stop

**BLOCKED** — No live OTP verification.

### 28. Delivery Success

**BLOCKED** — No POD upload.

### 29. Order History

**BLOCKED** — No delivery mutation.

### 30. Wallet

**PARTIAL** — Duplicate gesture guarded in widget tests only.

### 31. Earnings

**BLOCKED** — Tracking stop not field-tested.

### 32. Withdrawals

**PARTIAL** — Golden only, no delivered live order.

### 33. Chat

**PARTIAL** — History endpoint HTTP 200, empty list.

### 34. Media

**PARTIAL** — Profile finance fields present; no delivery financial effect.

### 35. Notifications

**PARTIAL** — Valid pending/withdrawn endpoints HTTP 200; no withdrawal sent.

### 36. Push Notifications

**PARTIAL** — Three conversation-list APIs HTTP 200; no device UI.

### 37. Profile

**NOT EXECUTED** — No message sent.

### 38. Vehicle

**BLOCKED** — No device media/file picker test.

### 39. Documents

**PARTIAL** — Notifications endpoint HTTP 200; UI not opened.

### 40. Bank

**BLOCKED** — FCM disabled for local QA.

### 41. Reviews

**PARTIAL** — Profile endpoint HTTP 200; no device walkthrough.

### 42. Emergency Contacts

**PARTIAL** — Onboarding profile endpoint HTTP 200; vehicle UI unverified.

### 43. Settings

**PARTIAL** — Onboarding profile endpoint HTTP 200; document UI unverified.

### 44. Language

**PARTIAL** — No bank UI/update.

### 45. Support

**PARTIAL** — Reviews endpoint HTTP 200; UI unverified.

### 46. Legal

**NOT EXECUTED** — No device language switch.

### 47. Maintenance

**NOT EXECUTED** — MediaViewer not opened.

### 48. Update

**NOT EXECUTED** — Bank edit not opened.

### 49. All 44 Screens Matrix

**PARTIAL** — Chat endpoints work; bubbles/filters unverified.

### 50. Light Mode QA

**PARTIAL** — No device dialog audit.

### 51. Dark Mode QA

**BLOCKED** — 44 screens inventoried; none device-walked.

### 52. RTL QA

**PARTIAL** — Selected 320x640 RTL goldens/widgets at 1.5 text scale; no Android device.

### 53. LTR QA

**PARTIAL** — Selected widget LTR cases only.

### 54. Small Screen QA

**BLOCKED** — No large device attached.

### 55. Large Screen QA

**BLOCKED** — No landscape device test.

### 56. Landscape

**PARTIAL** — Selected RTL golden cases only.

### 57. Accessibility

**PARTIAL** — No full RTL device pass.

### 58. Contrast

**PARTIAL** — No full LTR device pass.

### 59. Keyboard QA

**PARTIAL** — No TalkBack; selected text-scale/component tests only.

### 60. Offline UX

**PARTIAL** — No complete contrast audit.

### 61. API Failure UX

**PARTIAL** — No actual airplane-mode test; selected API refusal widget tests exist.

### 62. Session Expiry

**NOT EXECUTED** — No server-stop/recovery device test.

### 63. Suspension

**BLOCKED** — No comprehensive 401/403/422/500 device tests.

### 64. Logout

**BLOCKED** — No session-expiry device test.

### 65. Restart

**BLOCKED** — Account left active.

### 66. Process Kill

**BLOCKED** — Logout not exercised on device.

### 67. Permissions

**BLOCKED** — No installed app restart.

### 68. Privacy

**BLOCKED** — No process-kill test.

### 69. Performance Smoke

**PARTIAL** — Sanaa fallback removed and coordinate validation unit-tested; Android permissions untested.

### 70. Logcat

**BLOCKED** — Camera permission untested.

### 71. Phase 1 Regression

**PARTIAL** — Android notification permission untested; FCM disabled.

### 72. Phase 2 Regression

**BLOCKED** — No phone/email/map intents launched.

### 73. Phase 3 Regression

**PARTIAL** — Tracking start/stop/privacy unverified.

### 74. flutter analyze

**BLOCKED** — No device performance measurements.

### 75. flutter test

**BLOCKED** — No device Logcat.

### 76. APK Build

**PARTIAL** — Four Phase 1 tests passed; operational security flows not fully exercised.

### 77. APK SHA256

**PARTIAL** — Seven Phase 2 model/contract tests passed; wizard not walked.

### 78. Backend Changes

**BLOCKED** — No Phase 3 order journey.

### 79. Database/Test Fixture Changes

**PASS** — flutter analyze --no-pub: No issues found, exit 0.

### 80. Legacy UI Remaining

**PASS** — flutter test --no-pub: 40 passed, 0 failed, 0 skipped.

### 81. Known Issues

**PASS** — Local QA debug APK build completed.

### 82. Blockers

**PARTIAL** — تثبيت وتشغيل وتسجيل دخول الجهاز نجحت. رحلة الطلب متوقفة لغياب طلب محلي مسند.

### 83. Final Verdict

**PASS** — Updated 44-screen matrix with per-screen coverage; no blanket PASS.


## Legacy references

- SliderButtonWidget: SAFE UNUSED؛ لا مراجع استعمال خارج تعريفه؛ لم يُحذف.
- Matrix4 في animated_custom_dialog_widget: ACTIVE BUT NORMALIZED؛ حركة ظهور عامة وليست قلب RTL.
- Reviews/language/media/bank edit وبعض الحوارات والفلاتر وفقاعات chat: ACTIVE LEGACY — BLOCKER لإغلاق المظهر حتى المرور على الجهاز.
- لا تحذف بلا دليل؛ راجع ../phase4_1/legacy-references.txt.

## Remaining blockers

1. أنشئ أو أسند طلب اختبار محلي عبر مسار Admin/Seller المدعوم للحساب النشط، مع متجر وعميل وإحداثيات وبيانات دفع.
2. بعد توفر الطلب، نفذ رحلة Phase 3 والتتبع والخريطة وOTP/COD/POD وسجل الطلب وأثر المحفظة على الجهاز.
3. أعد فحوصات الإصدار بعد إكمال الرحلة.

**FINAL VERDICT: PHASE 4.2 PARTIAL.** تثبيت التطبيق وتسجيل الدخول ولوحة السائق نجحت على الجهاز. رحلة الطلب والخرائط والتتبع الخلفي لم تنفذ بسبب غياب طلب اختبار مسند. لا Phase 5 أو deploy/push/production.


Device update (2026-10-03): ADB authorized (Samsung SM-S918W, Android 15/API 35); adb install PASS; ADB reverse tcp:8000 PASS. UI login PASS and dashboard rendered with driver Online. Orders API returned HTTP 200 with 0 assigned rows; test-order journey remains BLOCKED. No order or backend/database records were created.

## Diagnostic artifact note

أثناء محاولة التقاط شاشة الإقلاع، حصل ADB على لقطة شاشة وتسلسل عناصر واجهة الجهاز بينما كان تطبيق خارجي في المقدمة، فتضمّنت تلك الأدلة المرئية محتوى ذلك التطبيق. لا تُشارك هذه اللقطات أو ملف UI hierarchy. طُلب حذف الملفات التشخيصية المحددة لكن أداة التنفيذ منعت الحذف بسياسة النظام؛ لذلك بقيت ضمن docs/phase4_2: device-boot.png, device-current.png, device-driver-relaunch.png, device-login-ui.xml, device-splash-after-network.png, device-unlock-check.png, driver-login.png. لا أفتحها أو أرفقها بالتقرير.


