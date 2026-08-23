import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllinePromoBannerWidget extends StatefulWidget {
  const AllinePromoBannerWidget({super.key});

  @override
  State<AllinePromoBannerWidget> createState() => _AllinePromoBannerWidgetState();
}

class _AllinePromoBannerWidgetState extends State<AllinePromoBannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _slides = [
    {
      'tag': 'عروض حصرية 🔥',
      'title': 'خصومات تصل إلى 50%',
      'subtitle': 'تسوق من أفضل المتاجر القريبة منك بأفضل الأسعار',
      'cta': 'تسوق الآن',
      'gradient': [const Color(0xFF1E40AF), const Color(0xFF2563EB)],
      'icon': Icons.local_offer_rounded,
    },
    {
      'tag': 'توصيل فوري ⚡',
      'title': 'طلبك يوصلك خلال دقائق',
      'subtitle': 'تتبع مباشر لمندوب التوصيل خطوة بخطوة',
      'cta': 'استكشف المتاجر',
      'gradient': [const Color(0xFF0F766E), const Color(0xFF0D9488)],
      'icon': Icons.delivery_dining_rounded,
    },
    {
      'tag': 'محفظة Alline 💳',
      'title': 'اشحن محفظتك واستمتع بالخصم',
      'subtitle': 'شحن فوري عبر جيب، ون كاش، وكريمي حاسب',
      'cta': 'اشحن الآن',
      'gradient': [const Color(0xFF4338CA), const Color(0xFF6366F1)],
      'icon': Icons.account_balance_wallet_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: slide['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (slide['gradient'][0] as Color).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative background icon
                      Positioned(
                        left: -10,
                        bottom: -15,
                        child: Icon(
                          slide['icon'] as IconData,
                          size: 110,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),

                      // Text Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              slide['tag'] as String,
                              style: textBold.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['title'] as String,
                            style: titilliumBold.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slide['subtitle'] as String,
                            style: textRegular.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${slide['cta']} ←',
                              style: textBold.copyWith(
                                color: slide['gradient'][0] as Color,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Carousel Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
