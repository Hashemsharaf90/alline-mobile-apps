import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/screens/supermarket_home_screen.dart';

/// Home service banners. Images are managed by the backend Banner module and
/// the bundled assets are kept as an offline fallback.
class AllineServicesGridWidget extends StatelessWidget {
  const AllineServicesGridWidget({super.key});

  static const _blue = Color(0xFF015FC9);
  static const _text = Color(0xFF071B49);
  static const _muted = Color(0xFF6D85AF);
  static const _surface = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, banners, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              _ServiceBanner(
                title: 'تسوق من العالم',
                subtitle: 'اطلب من المتاجر العالمية عبر Alline',
                fallback:
                    'assets/images/alline/alline_global_shopping_banner.png',
                remoteImage: banners.globalShoppingBanner?.photoFullUrl?.path,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const GlobalShoppingScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _ServiceBanner(
                title: 'تسوق من السوبر ماركت',
                subtitle: 'كل احتياجاتك اليومية في مكان واحد',
                fallback:
                    'assets/images/alline/alline_supermarket_banner_v2.png',
                remoteImage: banners.supermarketBanner?.photoFullUrl?.path,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const SupermarketHomeScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fallback;
  final String? remoteImage;
  final VoidCallback onTap;

  const _ServiceBanner({
    required this.title,
    required this.subtitle,
    required this.fallback,
    required this.remoteImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = remoteImage?.trim();
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AllineServicesGridWidget._surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 154,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null && image.isNotEmpty)
                  CustomImageWidget(
                    image: image,
                    fit: BoxFit.cover,
                    placeholder: fallback,
                  )
                else
                  Image.asset(fallback, fit: BoxFit.cover),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: 190,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [Color(0xF7FFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AllineServicesGridWidget._text,
                            fontSize: 17,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AllineServicesGridWidget._muted,
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AllineServicesGridWidget._blue,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            'تسوق الآن',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
