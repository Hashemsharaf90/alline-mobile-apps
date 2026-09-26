import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:provider/provider.dart';

class PriceConverter {
  // Currency values are rendered inside an Arabic (RTL) tree.  Wrapping the
  // complete price in an LTR isolate prevents the Unicode bidi algorithm from
  // visually moving a suffix such as "ريال" to the opposite side.
  static String _formatCurrency(String amount, String symbol, bool inRight) {
    final value = inRight ? '$amount $symbol' : '$symbol $amount';
    return '\u2066$value\u2069';
  }

  static String convertPrice(BuildContext context, double? price,
      {double? discount, String? discountType}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' || discountType == 'flat') {
        price = price! - discount;
      } else if (discountType == 'percent' || discountType == 'percentage') {
        price = price! - ((discount / 100) * price);
      }
    }
    final configModel =
        Provider.of<SplashController>(context, listen: false).configModel;
    if (configModel == null) {
      return price?.toString() ?? '';
    }
    bool singleCurrency = configModel.currencyModel == 'single_currency';
    final inRight =
        configModel.currencySymbolPosition?.trim().toLowerCase() == 'right';

    try {
      final splashProvider =
          Provider.of<SplashController>(context, listen: false);
      final amount = (singleCurrency
              ? price
              : price! *
                  splashProvider.myCurrency!.exchangeRate! *
                  (1 / splashProvider.usdCurrency!.exchangeRate!))!
          .toStringAsFixed(configModel.decimalPointSettings ?? 1)
          .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      return _formatCurrency(
          amount, splashProvider.myCurrency!.symbol ?? '', inRight);
    } catch (e) {
      return price.toString();
    }
  }

  static double? convertWithDiscount(BuildContext context, double? price,
      double? discount, String? discountType) {
    if (discountType == 'amount' || discountType == 'flat') {
      price = price! - discount!;
    } else if (discountType == 'percent' || discountType == 'percentage') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount' || type == 'flat') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent' || type == 'percentage') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(BuildContext context, double? price,
      double? discount, String? discountType) {
    final configModel =
        Provider.of<SplashController>(context, listen: false).configModel;
    if (configModel == null) {
      return '-$discount %';
    }
    return '-${(discountType == 'percent' || discountType == 'percentage') ? '${discount?.toStringAsFixed(configModel.decimalPointSettings ?? 1)} %' : convertPrice(context, discount)}';
  }

  static String getUnitCurrency(BuildContext context, double? price) {
    final splashProvider =
        Provider.of<SplashController>(context, listen: false);
    final configModel = splashProvider.configModel;
    if (configModel == null) {
      return price?.toString() ?? '';
    }
    bool singleCurrency = configModel.currencyModel == 'single_currency';
    final inRight =
        configModel.currencySymbolPosition?.trim().toLowerCase() == 'right';

    final amount = (singleCurrency ? price : price!)!
        .toStringAsFixed(configModel.decimalPointSettings ?? 1)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return _formatCurrency(
        amount, splashProvider.myCurrency?.symbol ?? '', inRight);
  }

  static String convertPriceWithoutSymbol(BuildContext context, double? price,
      {double? discount, String? discountType}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' || discountType == 'flat') {
        price = price! - discount;
      } else if (discountType == 'percent' || discountType == 'percentage') {
        price = price! - ((discount / 100) * price);
      }
    }
    final splashProvider =
        Provider.of<SplashController>(context, listen: false);
    final configModel = splashProvider.configModel;
    if (configModel == null) {
      return price?.toString() ?? '';
    }
    bool singleCurrency = configModel.currencyModel == 'single_currency';

    return (singleCurrency
            ? price
            : price! *
                (splashProvider.myCurrency?.exchangeRate ?? 1.0) *
                (1 / (splashProvider.usdCurrency?.exchangeRate ?? 1.0)))!
        .toStringAsFixed(configModel.decimalPointSettings ?? 1);
  }

  static String longToShortPrice(double amount,
      {bool withDecimalPoint = true}) {
    int decimalPoint = withDecimalPoint ? 2 : 0;

    if (amount.abs() >= 1e12) {
      return '${(amount / 1e12).toStringAsFixed(decimalPoint)}T';
    } else if (amount.abs() >= 1e9) {
      return '${(amount / 1e9).toStringAsFixed(decimalPoint)}B';
    } else if (amount.abs() >= 1e6) {
      return '${(amount / 1e6).toStringAsFixed(decimalPoint)}M';
    } else if (amount.abs() >= 1e3) {
      return '${(amount / 1e3).toStringAsFixed(decimalPoint)}K';
    } else {
      return amount.toStringAsFixed(decimalPoint);
    }
  }
}
