import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The onboarding screen owns navigation; this view can be previewed in isolation.
class AllineWelcomeView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onStart, onLogin, onLanguage;
  const AllineWelcomeView(
      {super.key,
      required this.isArabic,
      required this.onStart,
      required this.onLogin,
      required this.onLanguage});
  static const ink = Color(0xFF10244A),
      blue = Color(0xFF0866F5),
      muted = Color(0xFF6B7D99),
      background = Color(0xFFF5F9FF);
  static const heroAsset = 'assets/images/alline/welcome_shopping_hero.png';
  static const logoAsset = 'assets/images/alline/login_logo_transparent.png';
  String tr(String ar, String en) => isArabic ? ar : en;
  TextStyle text(double size, {Color color = ink, bool bold = false}) =>
      TextStyle(
          fontFamily: 'AllineTajawal',
          fontSize: size,
          height: 1.3,
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: background,
            systemNavigationBarIconBrightness: Brightness.dark),
        child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
                backgroundColor: background,
                body: Stack(children: [
                  const Positioned(
                      top: -160,
                      right: -125,
                      child: _Glow(size: 370, color: Color(0xFFE6F0FF))),
                  const Positioned(
                      bottom: -110,
                      left: -130,
                      child: _Glow(size: 280, color: Color(0xFFFFF0D6))),
                  SafeArea(child: LayoutBuilder(builder: (context, viewport) {
                    final heroHeight =
                        (viewport.maxHeight * .36).clamp(230.0, 345.0);
                    return SingleChildScrollView(
                        child: Center(
                            child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 480, minHeight: viewport.maxHeight),
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _header(),
                                const SizedBox(height: 14),
                                _heading(),
                                const SizedBox(height: 20),
                                _hero(heroHeight),
                                const SizedBox(height: 20),
                                _benefits(),
                                const SizedBox(height: 24),
                                _actions(),
                              ])),
                    )));
                  })),
                ]))),
      );

  Widget _header() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Image.asset(logoAsset,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            semanticLabel: 'Alline',
            filterQuality: FilterQuality.high),
        OutlinedButton.icon(
            onPressed: onLanguage,
            icon: const Icon(Icons.language_rounded, size: 19),
            label: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('العربية', 'English'), style: text(14, bold: true)),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18)
            ]),
            style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                backgroundColor: Colors.white.withValues(alpha: .8),
                side: const BorderSide(color: Color(0xFFDAE5F4)),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const StadiumBorder())),
      ]);

  Widget _heading() => Column(children: [
        Text(tr('مرحبًا بك في Alline', 'Welcome to Alline'),
            textAlign: TextAlign.center, style: text(16, color: muted)),
        const SizedBox(height: 10),
        Text(tr('كل ما تحب،', 'Everything you love,'),
            textAlign: TextAlign.center, style: text(34, bold: true)),
        Text(tr('في مكان واحد.', 'all in one place.'),
            textAlign: TextAlign.center,
            style: text(34, color: blue, bold: true)),
        const SizedBox(height: 10),
        Text(
            tr('تسوّق بسهولة .. لحياة أسهل',
                'Easy shopping. A simpler everyday.'),
            textAlign: TextAlign.center,
            style: text(15, color: muted)),
      ]);

  Widget _hero(double height) => Semantics(
        label: tr('اكتشف عالم Alline من الأزياء والإلكترونيات والجمال',
            'Discover fashion, electronics and beauty at Alline'),
        image: true,
        child: ExcludeSemantics(
            child: Container(
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF164989).withValues(alpha: .08),
                    offset: const Offset(0, 14),
                    blurRadius: 30,
                    spreadRadius: -12)
              ]),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(heroAsset,
                  fit: BoxFit.cover, filterQuality: FilterQuality.high)),
        )),
      );

  Widget _benefits() =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _benefit(Icons.shopping_bag_outlined,
            tr('منتجات متنوعة', 'More to discover')),
        _benefit(
            Icons.two_wheeler_rounded, tr('توصيل سريع', 'Fast delivery')),
        _benefit(
            Icons.verified_user_outlined, tr('تسوّق آمن', 'Secure shopping')),
      ]);
  Widget _benefit(IconData icon, String label) => Expanded(
          child: Column(children: [
        Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EAF6))),
            child: Icon(icon, size: 22, color: blue)),
        const SizedBox(height: 8),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(label,
                textAlign: TextAlign.center, style: text(12, bold: true))),
      ]));

  Widget _actions() =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        DecoratedBox(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1680FF), Color(0xFF0754DC)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: blue.withValues(alpha: .22),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ]),
            child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Row(children: [
                  const SizedBox(width: 28),
                  Expanded(
                      child: Text(tr('ابدأ الآن', 'Start exploring'),
                          textAlign: TextAlign.center,
                          style: text(20, color: Colors.white, bold: true))),
                  const Icon(Icons.arrow_forward_rounded, size: 24),
                ]))),
        const SizedBox(height: 14),
        Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(tr('لديك حساب بالفعل؟', 'Already have an account?'),
                  style: text(14, color: muted)),
              TextButton(
                  onPressed: onLogin,
                  style: TextButton.styleFrom(
                      foregroundColor: blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12)),
                  child: Text(tr('تسجيل الدخول', 'Sign in'),
                      style: text(14, color: blue, bold: true))),
            ]),
      ]);
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                  colors: [color, color.withValues(alpha: 0)]))));
}
