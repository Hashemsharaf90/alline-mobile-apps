import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reference-matched first-run welcome screen for Alline.
class AllineWelcomeView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final VoidCallback onGuest;
  final VoidCallback onLanguage;

  const AllineWelcomeView({
    super.key,
    required this.isArabic,
    required this.onRegister,
    required this.onLogin,
    required this.onGuest,
    required this.onLanguage,
  });

  static const _blue = Color(0xFF0757D5);
  static const _ink = Color(0xFF071B49);
  static const _orange = Color(0xFFF59A0B);
  static const _muted = Color(0xFF4F5870);
  static const _heroAsset =
      'assets/images/alline/welcome_reference_hero.png';
  static const _logoAsset =
      'assets/images/alline/login_logo_transparent.png';

  String tr(String ar, String en) => isArabic ? ar : en;

  TextStyle _text(
    double size, {
    Color color = _ink,
    FontWeight weight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: 'AllineTajawal',
      fontSize: size,
      height: 1.25,
      color: color,
      fontWeight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) {
                final compact = viewport.maxHeight < 740;
                final heroHeight = compact ? 245.0 : 315.0;
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 460,
                        minHeight: viewport.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          compact ? 12 : 20,
                          24,
                          18 + bottomInset,
                        ),
                        child: Column(
                          children: [
                            _logo(compact),
                            SizedBox(height: compact ? 2 : 10),
                            _hero(heroHeight),
                            SizedBox(height: compact ? 8 : 14),
                            _headline(compact),
                            SizedBox(height: compact ? 18 : 28),
                            _actions(compact),
                            SizedBox(height: compact ? 16 : 28),
                            _languageSwitcher(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo(bool compact) {
    return Semantics(
      image: true,
      label: 'Alline',
      child: Image.asset(
        _logoAsset,
        width: compact ? 190 : 240,
        height: compact ? 106 : 132,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _hero(double height) {
    return Semantics(
      image: true,
      label: tr(
        'تجربة تسوق متكاملة من Alline',
        'A complete shopping experience from Alline',
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Image.asset(
          _heroAsset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _headline(bool compact) {
    return Column(
      children: [
        Text(
          tr('كل احتياجاتك في مكان واحد', 'All your needs in one place'),
          textAlign: TextAlign.center,
          style: _text(compact ? 27 : 31, weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          width: compact ? 64 : 80,
          height: 5,
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: _text(compact ? 16 : 18, color: _muted),
            children: isArabic
                ? [
                    const TextSpan(text: 'تسوّق، ادفع، واستلم بسهولة مع '),
                    TextSpan(
                      text: 'Alline',
                      style: _text(
                        compact ? 16 : 18,
                        color: _blue,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ]
                : [
                    const TextSpan(text: 'Shop, pay, and receive with '),
                    TextSpan(
                      text: 'Alline',
                      style: TextStyle(
                        fontFamily: 'SF-Pro-Rounded-Regular',
                        fontSize: 18,
                        color: _blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _actions(bool compact) {
    final height = compact ? 52.0 : 58.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              tr('إنشاء حساب', 'Create account'),
              style: _text(compact ? 19 : 21,
                  color: Colors.white, weight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: height,
          child: OutlinedButton(
            onPressed: onLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              tr('تسجيل الدخول', 'Sign in'),
              style: _text(compact ? 19 : 21,
                  color: _blue, weight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onGuest,
          style: TextButton.styleFrom(
            foregroundColor: _blue,
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            tr('المتابعة كزائر', 'Continue as guest'),
            style: _text(16, color: _blue, weight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _languageSwitcher() {
    return TextButton(
      onPressed: onLanguage,
      style: TextButton.styleFrom(
        foregroundColor: _ink,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: RichText(
        text: TextSpan(
          style: _text(16, color: _ink),
          children: [
            TextSpan(
              text: 'العربية',
              style: _text(16,
                  color: isArabic ? _blue : _ink,
                  weight: isArabic ? FontWeight.w700 : FontWeight.w400),
            ),
            TextSpan(text: '   |   ', style: _text(16, color: _muted)),
            TextSpan(
              text: 'English',
              style: _text(16,
                  color: isArabic ? _ink : _blue,
                  weight: isArabic ? FontWeight.w400 : FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
