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
  State<GlobalProductPreviewCard> createState() =>
      _GlobalProductPreviewCardState();
}

class _GlobalProductPreviewCardState extends State<GlobalProductPreviewCard> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;
    final globalCtrl = Provider.of<GlobalShoppingController>(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            width: 1.5),
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
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusDefault)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Theme.of(context).primaryColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  isLtr
                      ? 'Product Identified from ${widget.preview.storeName}'
                      : 'تم التعرف على المنتج من ${widget.preview.storeName}',
                  style: textBold.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall),
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
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      child: Container(
                        width: 90,
                        height: 90,
                        color: isDark
                            ? Theme.of(context).highlightColor
                            : const Color(0xFFF9FAFB),
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
                            style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          if (widget.preview.currentPrice != null &&
                              widget.preview.originalCurrency != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${widget.preview.currentPrice!.toStringAsFixed(2)} ${widget.preview.originalCurrency}',
                              textDirection: TextDirection.ltr,
                              style: textBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            if (widget.preview.convertedCurrentPrice != null &&
                                widget.preview.convertedCurrency != null)
                              Text(
                                '≈ ${widget.preview.convertedCurrentPrice!.toStringAsFixed(0)} ${widget.preview.convertedCurrency}',
                                textDirection: TextDirection.ltr,
                                style: textRegular.copyWith(
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Pricing is intentionally manual; no shipping or fees are fabricated.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).primaryColor, size: 19),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLtr
                              ? 'The displayed amount is the source product price only. Shipping, customs, and service fees are quoted by Alline after review.'
                              : 'السعر الظاهر هو سعر المنتج في المتجر فقط. يحدد فريق Alline الشحن والجمارك ورسوم الخدمة بعد مراجعة الطلب.',
                          style: textRegular.copyWith(
                            fontSize: 11,
                            height: 1.4,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Quantity Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLtr ? 'Quantity:' : 'الكمية المطلوبة:',
                      style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text('$_quantity',
                              style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault)),
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
                    hintText: isLtr
                        ? 'Add notes (e.g. Color, Size, Specs)'
                        : 'أضف ملاحظات (مثال: اللون، المقاس، المواصفات المطلوبة)',
                    hintStyle: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor),
                    filled: true,
                    fillColor: isDark
                        ? Theme.of(context).highlightColor
                        : const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Manual quote status; never imply this is the landed total.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLtr ? 'Price confirmation' : 'تأكيد السعر النهائي',
                          style: textBold.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLtr
                              ? 'Submit this product for manual review. It will be added to your Alline cart after the quote is approved.'
                              : 'أرسل المنتج للمراجعة اليدوية. سيظهر في سلة Alline بعد اعتماد السعر والمنتج.',
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.4,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
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
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall)),
                    ),
                    onPressed: globalCtrl.isSubmitLoading
                        ? null
                        : () async {
                            final success = await globalCtrl.submitRequest(
                              productUrl: widget.preview.productUrl ?? '',
                              storeName: widget.preview.storeName,
                              quantity: _quantity,
                              customerNotes: _notesController.text.trim(),
                              onSuccess: () => showCustomSnackBarWidget(
                                  'تم إرسال طلب التسعير. ستتم إضافته للسلة بعد اعتماد السعر.',
                                  context,
                                  snackBarType: SnackBarType.success),
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
                              const Icon(Icons.shopping_bag_outlined,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isLtr
                                ? 'Request manual quote'
                                    : 'إرسال للمراجعة والتسعير',
                                style: textBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeDefault),
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

}
