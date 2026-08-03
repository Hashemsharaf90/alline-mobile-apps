import 'package:get/get.dart';

class Dimensions {
  static double get _width => Get.context?.width ?? 411.0;
  static bool get _isCompact => _width <= 400;

  static double get fontSizeExtraSmall => _isCompact ? 10.0 : 10.0;
  static double get fontSizeSmall => _isCompact ? 12 : 12.0;
  static double get fontSizeDefault => _isCompact ? 14 : 14.0;
  static double get fontSizeLarge => _isCompact ? 14 : 16.0;
  static double get fontSizeExtraLarge => _isCompact ? 16 : 18.0;
  static double get fontSizeHeading => _isCompact ? 18 : 22.0;
  static double get fontSizeOverLarge => _isCompact ? 20 : 24.0;
  static double get fontSizeHeadingLarge => _isCompact ? 24 : 30.0;

  static double get paddingSizeExtraSmall => _isCompact ? 3 : 5.0;
  static double get paddingSizeMin => _isCompact ? 5 : 7.0;
  static double get paddingSizeSmall => _isCompact ? 8 : 10.0;
  static double get radiusSmall => _isCompact ? 8 : 10.0;
  static double get paddingSizeChat => _isCompact ? 10 : 12.0;
  static double get paddingSizeDefault => _isCompact ? 12 : 15.0;
  static double get rememberMeSizeDefault => _isCompact ? 15 : 18.0;
  static double get paddingSizeLarge => _isCompact ? 17 : 20.0;
  static double get paddingSizeExtraLarge => _isCompact ? 21 : 25.0;
  static double get paddingSizeOverLarge => _isCompact ? 25 : 30.0;
  static double get topSpace => _isCompact ? 35 : 40.0;
  static double get loginSpace => _isCompact ? 30 : 35.0;

  static double get flagSize => _isCompact ? 25 : 34.0;
  static double get searchRadius => _isCompact ? 28 : 37.0;
  static double get productImageSizeOrderDetails => _isCompact ? 50 : 70.0;
  static double get profileImageSize => _isCompact ? 35 : 50.0;
  static double get menuProfileImageSize => _isCompact ? 80 : 100.0;
  static double get splashLogoWidth => _isCompact ? 120 : 150.0;

  static double get loginColor => _isCompact ? 140 : 140.0;
  static double get skipSpace => _isCompact ? 80 : 100.0;

  static double get dashboardCardHeight => _isCompact ? 200 : 250.0;


  static const double iconSizeSmall = 3.0;
  static const double iconSizeMedium = 15.0;
  static const double iconSizeMediumSmall = 10.0;
  static const double iconSizeDefault = 17.0;
  static const double iconSizeMenu = 22.0;
  static const double iconSizeLarge = 30.0;
  static const double iconSizeExtraLarge = 50.0;
  static const double dashWidth = 5.0;
  static const double logoHeight = 30.0;
  static const int messageInputLength = 250;

  static const double radiusLarge = 15;
  static const double radiusDefault = 10.0;
  static const double radiusExtraLarge = 20.0;

  static const double chatProfileSize = 45.0;

}
