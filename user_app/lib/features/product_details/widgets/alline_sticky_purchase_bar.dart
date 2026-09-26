import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/shipping_method_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

/// Alline Sticky Purchase Bar.
///
/// Features:
/// - Fixed at the bottom of the screen with Safe Area padding
/// - Primary CTA: "إضافة إلى السلة" (Alline Blue, large, high-contrast)
/// - Secondary CTA: "شراء الآن"
/// - Disabled out-of-stock state
/// - Instant feedback on tap with reactive cart counter sync
class AllineStickyPurchaseBar extends StatefulWidget {
  final ProductDetailsModel? product;

  const AllineStickyPurchaseBar({super.key, required this.product});

  @override
  State<AllineStickyPurchaseBar> createState() => _AllineStickyPurchaseBarState();
}

class _AllineStickyPurchaseBarState extends State<AllineStickyPurchaseBar> {
  static const _primary = AllineColors.primary;
  static const _darkBlue = AllineColors.primaryDark;
  static const _border = Color(0xFFE1E8F2);
  static const _softBlue = Color(0xFFF4F8FE);
  static const _secondary = Color(0xFF6D85AF);

  bool _isShopClosed(BuildContext context) {
    final product = widget.product;
    if (product == null) return false;

    final bool isInHouse = product.addedBy == 'admin';
    final splash = Provider.of<SplashController>(context, listen: false);

    final bool isVacationActive = ShopHelper.isVacationActive(
      context,
      startDate: product.seller?.shop?.vacationStartDate,
      endDate: product.seller?.shop?.vacationEndDate,
      vacationDurationType: product.seller?.shop?.vacationDurationType,
      vacationStatus: product.seller?.shop?.vacationStatus,
      isInHouseSeller: isInHouse,
    );

    final bool isTempClosed = isInHouse
        ? (splash.configModel?.inhouseTemporaryClose?.status ?? false)
        : (product.seller?.shop?.temporaryClose ?? false);

    return isVacationActive || isTempClosed;
  }

  ({int stock, Variation? variation, String variationType}) _resolveVariation(
      ProductDetailsController details) {
    final product = widget.product!;
    int stock = product.currentStock ?? 0;
    Variation? variation;

    String? variantName = (product.colors != null &&
            product.colors!.isNotEmpty &&
            (details.variantIndex ?? 0) < product.colors!.length)
        ? product.colors![details.variantIndex ?? 0].name
        : null;

    List<String> variationList = [];
    for (int i = 0; i < (product.choiceOptions?.length ?? 0); i++) {
      int optIndex = (details.variationIndex != null &&
              i < details.variationIndex!.length)
          ? details.variationIndex![i]
          : 0;
      if (optIndex < (product.choiceOptions![i].options?.length ?? 0)) {
        variationList.add(product.choiceOptions![i].options![optIndex].trim());
      }
    }

    String variationType = '';
    if (variantName != null) {
      variationType = variantName;
      for (var v in variationList) {
        variationType = '$variationType-$v';
      }
    } else {
      bool isFirst = true;
      for (var v in variationList) {
        if (isFirst) {
          variationType = v;
          isFirst = false;
        } else {
          variationType = '$variationType-$v';
        }
      }
    }
    variationType = variationType.replaceAll(' ', '');

    if (product.variation != null) {
      for (Variation v in product.variation!) {
        if (v.type == variationType) {
          variation = v;
          stock = v.qty ?? 0;
          break;
        }
      }
    }

    return (stock: stock, variation: variation, variationType: variationType);
  }

  CartModelBody _buildCartModel(
      ProductDetailsController details, Variation? variation) {
    final product = widget.product!;
    final variantIndex = details.variantIndex ?? 0;

    return CartModelBody(
      productId: product.id,
      variant: (product.colors != null &&
              product.colors!.isNotEmpty &&
              variantIndex < product.colors!.length)
          ? product.colors![variantIndex].name
          : '',
      color: (product.colors != null &&
              product.colors!.isNotEmpty &&
              variantIndex < product.colors!.length)
          ? product.colors![variantIndex].code
          : '',
      variation: variation,
      quantity: details.quantity ?? product.minimumOrderQty ?? 1,
    );
  }

  Future<void> _handleAddToCart(
      BuildContext context, ProductDetailsController details) async {
    final product = widget.product;
    if (product == null) return;

    if (_isShopClosed(context)) {
      showCustomSnackBarWidget(
        'المتجر مغلق حاليًا ولا يستقبل طلبات جديدة',
        context,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    final resolved = _resolveVariation(details);
    final minQty = product.minimumOrderQty ?? 1;

    if (product.productType == 'physical' && resolved.stock < minQty) {
      showCustomSnackBarWidget(
        'هذا المنتج غير متوفر حاليًا بالكمية المطلوبة',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    final cart = _buildCartModel(details, resolved.variation);
    final cartCtrl = Provider.of<CartController>(context, listen: false);
    if (cartCtrl.addToCartLoading) return;

    final ApiResponseModel res = await cartCtrl.addToCartAPI(
      cart,
      context,
      product.choiceOptions ?? [],
      details.variationIndex,
    );

    if (res.response?.statusCode == 200) {
      showCustomSnackBarWidget(
        'تمت إضافة المنتج إلى السلة بنجاح',
        Get.context!,
        snackBarType: SnackBarType.success,
      );
    }
  }

  Future<void> _handleBuyNow(
      BuildContext context, ProductDetailsController details) async {
    final product = widget.product;
    if (product == null) return;

    final authCtrl = Provider.of<AuthController>(context, listen: false);
    final splashCtrl = Provider.of<SplashController>(context, listen: false);

    if (splashCtrl.configModel?.guestCheckOut == 0 && !authCtrl.isLoggedIn()) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (_) => const NotLoggedInBottomSheetWidget(
            fromPage: RouterHelper.productDetailsScreen),
      );
      return;
    }

    if (_isShopClosed(context)) {
      showCustomSnackBarWidget(
        'المتجر مغلق حاليًا ولا يستقبل طلبات جديدة',
        context,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    final resolved = _resolveVariation(details);
    final minQty = product.minimumOrderQty ?? 1;

    if (product.productType == 'physical' && resolved.stock < minQty) {
      showCustomSnackBarWidget(
        'هذا المنتج غير متوفر حاليًا',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    final cart = _buildCartModel(details, resolved.variation);
    final cartCtrl = Provider.of<CartController>(context, listen: false);
    if (cartCtrl.addToCartLoading) return;

    final ApiResponseModel apiResponse = await cartCtrl.addToCartAPI(
      cart,
      context,
      product.choiceOptions ?? [],
      details.variationIndex,
      buyNow: 1,
    );

    if (apiResponse.response?.statusCode == 200) {
      _processBuyNowResponse(
        cart,
        product.choiceOptions ?? [],
        details.variationIndex,
        apiResponse.response,
      );
    }
  }

  void _processBuyNowResponse(
    CartModelBody cart,
    List<ChoiceOptions> choices,
    List<int>? variationIndexes,
    Response<dynamic>? response,
  ) {
    final bool selectShipping =
        response?.data != null && response?.data['shipping_method_list'] != null;

    if (selectShipping) {
      List<ShippingMethodModel> shippingList = [];
      response?.data['shipping_method_list'].forEach((el) {
        shippingList.add(ShippingMethodModel.fromJson(el));
      });

      showDialog(
        context: Get.context!,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: ChooseShippingMethodDialog(
            shippingList,
            cart,
            choices,
            variationIndexes,
            _navigateToCheckoutScreen,
          ),
        ),
      );
    } else if (response?.data?['cart'] != null) {
      final cartModel = CartModel.fromJson(response?.data['cart']);
      _navigateToCheckoutScreen(context, cartModel, 0.0);
    }
  }

  void _navigateToCheckoutScreen(
      BuildContext context, CartModel cart, double shippingCost) {
    final double discount = (cart.discount ?? 0) * (cart.quantity ?? 1);
    final double amount =
        ((cart.price ?? 0) - (cart.discount ?? 0)) * (cart.quantity ?? 1);
    final int totalQuantity = cart.quantity ?? 0;
    final bool hasPhysical = cart.productType == 'physical';
    double tax = 0.0;
    double shippingAmount = shippingCost + (cart.shippingCost ?? 0);

    if (cart.taxModel == 'exclude') {
      tax += (cart.tax ?? 0) * (cart.quantity ?? 1);
    }

    if (cart.freeDeliveryOrderAmount != null) {
      shippingAmount = shippingAmount -
          (cart.freeDeliveryOrderAmount!.shippingCostSaved ?? 0);
    }

    RouterHelper.getCheckoutScreenRoute(
      action: RouteAction.push,
      cartList: [cart],
      fromProductDetails: false,
      totalOrderAmount: amount,
      shippingFee: shippingAmount,
      discount: discount,
      tax: tax,
      sellerId: null,
      onlyDigital: !hasPhysical,
      hasPhysical: hasPhysical,
      quantity: totalQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    if (product == null) return const SizedBox.shrink();

    return Consumer2<ProductDetailsController, CartController>(
      builder: (context, details, cartCtrl, _) {
        final resolved = _resolveVariation(details);
        final bool isOutOfStock =
            product.productType == 'physical' && resolved.stock <= 0;
        final bool isLoading = cartCtrl.addToCartLoading;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: _border)),
            boxShadow: [
              BoxShadow(
                color: _darkBlue.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: isOutOfStock
              ? Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'هذا المنتج غير متوفر حاليًا',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _secondary,
                    ),
                  ),
                )
              : Row(
                  children: [
                    // Secondary CTA: "شراء الآن"
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => _handleBuyNow(context, details),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _primary, width: 1.5),
                            backgroundColor: _softBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'شراء الآن',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Primary CTA: "إضافة إلى السلة"
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _handleAddToCart(context, details),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_shopping_cart_rounded,
                                        size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'إضافة إلى السلة',
                                      style: TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
