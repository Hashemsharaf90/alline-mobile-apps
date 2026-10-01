import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class GlobalHeroBannerWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const GlobalHeroBannerWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE1E8F2), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF015FC9).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: AspectRatio(
            aspectRatio: 928 / 456,
            child: Image.asset(
              Images.globalShoppingHeroBanner,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback illustration container
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF4F8FE),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'العالم أقرب مع Alline',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF071B49),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'اكتشف منتجات من متاجر عالمية، أو أرسل رابط المنتج الذي تريده.',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 12,
                                color: Color(0xFF6D85AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.public, size: 48, color: Color(0xFF015FC9)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
