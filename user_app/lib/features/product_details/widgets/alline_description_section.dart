import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Alline Product Description Section ("عن المنتج").
///
/// Features:
/// - Section header
/// - Rich HTML description rendering
/// - Expandable toggle ("عرض المزيد" / "عرض أقل") with smooth transition
class AllineDescriptionSection extends StatefulWidget {
  final ProductDetailsModel? product;

  const AllineDescriptionSection({super.key, required this.product});

  @override
  State<AllineDescriptionSection> createState() =>
      _AllineDescriptionSectionState();
}

class _AllineDescriptionSectionState extends State<AllineDescriptionSection> {
  bool _isExpanded = false;

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);

  @override
  Widget build(BuildContext context) {
    final rawDetails = widget.product?.details;
    if (rawDetails == null || rawDetails.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final cleanHtml = ProductHelper.removeIframe(rawDetails);
    final bool isLong = cleanHtml.length > 250;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'عن المنتج',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 10),

          // Content with MaxHeight constraint when collapsed
          AnimatedCrossFade(
            firstChild: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: HtmlWidget(
                      cleanHtml,
                      textStyle: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                        color: _text,
                        height: 1.6,
                      ),
                      onTapUrl: (url) => launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ),
                  if (isLong)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            secondChild: HtmlWidget(
              cleanHtml,
              textStyle: const TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14,
                color: _text,
                height: 1.6,
              ),
              onTapUrl: (url) => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
            ),
            crossFadeState: (_isExpanded || !isLong)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Expand / Collapse Toggle
          if (isLong) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'عرض أقل' : 'عرض المزيد',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
