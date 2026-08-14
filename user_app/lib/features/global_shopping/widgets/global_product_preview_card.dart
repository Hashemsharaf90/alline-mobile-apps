import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_product_preview_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class GlobalProductPreviewCard extends StatefulWidget {
  final GlobalProductPreviewModel preview;
  final VoidCallback onSubmit;

  const GlobalProductPreviewCard({
    super.key,
    required this.preview,
    required this.onSubmit,
  });

  @override
  State<GlobalProductPreviewCard> createState() => _GlobalProductPreviewCardState();
}

class _GlobalProductPreviewCardState extends State<GlobalProductPreviewCard> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  bool _showCostBreakdown = false;

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    final globalCtrl = Provider.of<GlobalShoppingController>(context);

    final isAir = globalCtrl.selectedShippingType == 'air';
    final shippingCost = isAir ? (widget.preview.airShippingCost ?? 0.0) : (widget.preview.seaShippingCost ?? 0.0);
    final totalUsd = ((widget.preview.originalPrice ?? 0.0) + shippingCost + (widget.preview.customsFee ?? 0.0) + (widget.preview.serviceFee ?? 0.0)) * _quantity;
    final totalYer = totalUsd * 535.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  isLtr ? 'Product Identified from ${widget.preview.storeName}' : 'تم التعرف على المنتج من ${widget.preview.storeName}',
                  style: textBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Container(
                        width: 90,
                        height: 90,
                        color: isDark ? Theme.of(context).highlightColor : const Color(0xFFF9FAFB),
                        child: CustomImageWidget(
                          image: widget.preview.thumbnail ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.preview.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'وزن تقريبي: ${widget.preview.estimatedWeightKg} كجم',
                                  style: textRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Shipping Method Selector
                Text(
                  isLtr ? 'Select International Shipping' : 'اختر طريقة الشحن الدولي لليمن:',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _shippingOption(
                        context,
                        title: isLtr ? 'Air Express ✈️' : 'شحن جوي سريع ✈️',
                        duration: widget.preview.deliveryTimeAir ?? '7 - 12 days',
                        isSelected: isAir,
                        onTap: () => globalCtrl.setShippingType('air'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _shippingOption(
                        context,
                        title: isLtr ? 'Sea Cargo 🚢' : 'شحن بحري اقتصادي 🚢',
                        duration: widget.preview.deliveryTimeSea ?? '25 - 35 days',
                        isSelected: !isAir,
                        onTap: () => globalCtrl.setShippingType('sea'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Quantity Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLtr ? 'Quantity:' : 'الكمية المطلوبة:',
                      style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          ),
                          Text('$_quantity', style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Customer Notes / Variation
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: isLtr ? 'Add notes (e.g. Color, Size, Specs)' : 'أضف ملاحظات (مثال: اللون، المقاس، المواصفات المطلوبة)',
                    hintStyle: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    filled: true,
                    fillColor: isDark ? Theme.of(context).highlightColor : const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Price Summary & Breakdown Accordion
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLtr ? 'Total Landed Cost (Est.)' : 'التكلفة الإجمالية التقديرية الواصلة:',
                                style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${totalYer.toStringAsFixed(0)} YER',
                                style: textBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                              ),
                              Text(
                                '≈ \$${totalUsd.toStringAsFixed(2)} USD',
                                style: textRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() => _showCostBreakdown = !_showCostBreakdown),
                            icon: Icon(_showCostBreakdown ? Icons.expand_less : Icons.expand_more, size: 18),
                            label: Text(
                              isLtr ? 'Details' : 'التفاصيل',
                              style: textMedium.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      if (_showCostBreakdown) ...[
                        const Divider(height: 16),
                        _breakdownRow(context, isLtr ? 'Product Base Price' : 'سعر السلعة الأصلي', '\$${((widget.preview.originalPrice ?? 0.0) * _quantity).toStringAsFixed(2)}'),
                        _breakdownRow(context, isLtr ? 'International Shipping' : 'الشحن الدولي', '\$${(shippingCost * _quantity).toStringAsFixed(2)}'),
                        _breakdownRow(context, isLtr ? 'Customs & Handling' : 'الجمارك والمناولة', '\$${((widget.preview.customsFee ?? 0.0) * _quantity).toStringAsFixed(2)}'),
                        _breakdownRow(context, isLtr ? 'Service Fee' : 'عمولة الخدمة', '\$${((widget.preview.serviceFee ?? 0.0) * _quantity).toStringAsFixed(2)}'),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    ),
                    onPressed: globalCtrl.isSubmitLoading
                        ? null
                        : () async {
                            final success = await globalCtrl.submitRequest(
                              productUrl: widget.preview.productUrl ?? '',
                              storeName: widget.preview.storeName,
                              quantity: _quantity,
                              customerNotes: _notesController.text.trim(),
                              onSuccess: () => showCustomSnackBarWidget('تم إرسال طلب الشراء بنجاح! سيتم تسعيره وتأكيده خلال دقائق.', context, snackBarType: SnackBarType.success),
                            );
                            if (success) {
                              widget.onSubmit();
                            }
                          },
                    child: globalCtrl.isSubmitLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isLtr ? 'Confirm & Send Request' : 'تأكيد وإرسال طلب الشراء',
                                style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shippingOption(
    BuildContext context, {
    required String title,
    required String duration,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : (isDark ? Theme.of(context).highlightColor : const Color(0xFFF9FAFB)),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textBold.copyWith(
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              duration,
              style: textRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor)),
          Text(value, style: textMedium.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
