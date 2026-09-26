import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:provider/provider.dart';

class AllinePriceWidget extends StatelessWidget {
  final double? price;
  final double? discount;
  final String? discountType;
  final bool isOldPrice;
  final TextStyle? style;
  final Color? color;

  const AllinePriceWidget({
    super.key,
    required this.price,
    this.discount,
    this.discountType,
    this.isOldPrice = false,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (price == null) return const SizedBox.shrink();

    // 1. Calculate actual price after discount if applicable
    double currentPrice = price!;
    if (!isOldPrice && discount != null && discountType != null) {
      if (discountType == 'amount' || discountType == 'flat') {
        currentPrice = currentPrice - discount!;
      } else if (discountType == 'percent' || discountType == 'percentage') {
        currentPrice = currentPrice - ((discount! / 100) * currentPrice);
      }
    }

    // 2. Format Amount with commas
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    final configModel = splashProvider.configModel;
    bool singleCurrency = configModel?.currencyModel == 'single_currency';

    double convertedPrice = currentPrice;
    if (configModel != null && !singleCurrency) {
      convertedPrice = currentPrice *
          (splashProvider.myCurrency?.exchangeRate ?? 1.0) *
          (1 / (splashProvider.usdCurrency?.exchangeRate ?? 1.0));
    }

    final amountStr = convertedPrice
        .toStringAsFixed(configModel?.decimalPointSettings ?? 0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    // 3. Currency symbol (Dynamic from backend admin panel)
    final currencyStr = splashProvider.myCurrency?.symbol ?? 'ر.ي';
    final isRight = configModel?.currencySymbolPosition?.trim().toLowerCase() == 'right';

    // 4. Styles
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ??
        (isDark ? AllineColors.darkBrightBlue : AllineColors.priceBlue);

    final baseStyle = style ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              color: defaultColor,
              fontWeight: FontWeight.w700,
            ) ??
        TextStyle(
          color: defaultColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        );

    final actualStyle = isOldPrice
        ? baseStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: baseStyle.color?.withValues(alpha: 0.6) ?? Colors.grey,
          )
        : baseStyle;

    final currencyStyle = actualStyle.copyWith(
      fontSize: (actualStyle.fontSize ?? 14) * 0.85,
      fontWeight: isOldPrice ? FontWeight.w400 : FontWeight.w500,
    );

    // 5. Structure (Dynamic order based on backend admin panel)
    // We use LTR to ensure numbers don't flip with Arabic words, and we manually order the widgets.
    final List<Widget> children = isRight
        ? [
            Flexible(
              child: Text(
                amountStr,
                style: actualStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(currencyStr, style: currencyStyle),
          ]
        : [
            Text(currencyStr, style: currencyStyle),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                amountStr,
                style: actualStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: children,
      ),
    );
  }
}
