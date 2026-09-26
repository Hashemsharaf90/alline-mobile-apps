import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_skeleton_widget.dart';
import 'package:provider/provider.dart';

/// "عروض السوبر ماركت" section.
///
/// Filters [ProductController.supermarketProductModel] to products that have
/// a discount, and displays them in a horizontal scroll.
class SmOffersWidget extends StatelessWidget {
  const SmOffersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, ctrl, _) {
        final model = ctrl.supermarketProductModel;

        // Still loading
        if (model == null) {
          return _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AllineSectionHeader(
                  title: '\u0639\u0631\u0648\u0636 \u0627\u0644\u0633\u0648\u0628\u0631 \u0645\u0627\u0631\u0643\u062a',
                ),
                const SizedBox(height: 14),
                const SmProductListSkeleton(),
              ],
            ),
          );
        }

        final offers = (model.products ?? <Product>[])
            .where((p) =>
                (p.discount != null && p.discount! > 0) ||
                (p.clearanceSale?.discountAmount ?? 0) > 0)
            .toList();

        if (offers.isEmpty) return const SizedBox.shrink();

        return _Section(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AllineSectionHeader(
                title: '\u0639\u0631\u0648\u0636 \u0627\u0644\u0633\u0648\u0628\u0631 \u0645\u0627\u0631\u0643\u062a',
                subtitle: '\u062e\u0635\u0648\u0645\u0627\u062a \u062d\u0635\u0631\u064a\u0629 \u0639\u0644\u0649 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0627\u0644\u0623\u0633\u0627\u0633\u064a\u0629',
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 252,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      SizedBox(
                        width: 150,
                        child: SupermarketProductCard(
                          product: offers[index],
                          margin: 0,
                        ),
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        child: child,
      );
}
