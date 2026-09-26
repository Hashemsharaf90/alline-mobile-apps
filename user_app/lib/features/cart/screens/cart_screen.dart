import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_loader_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/circular_progress_with_logo.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/cart_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/cart_page_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/cart_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_state_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_card.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final bool fromCheckout;
  final int sellerId;
  final bool showBackButton;
  final bool fromDashboard;
  const CartScreen(
      {super.key,
      this.fromCheckout = false,
      this.sellerId = 1,
      this.showBackButton = true,
      this.fromDashboard = false});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final List<GlobalKey> sellerKeys = [];
  bool validated = false;
  bool singleVendor = false;
  bool _checkoutInProgress = false;

  Future<void> _loadData() async {
    await Provider.of<CartController>(Get.context!, listen: false)
        .getCartData(Get.context!);
    Provider.of<CartController>(Get.context!, listen: false).setCartData();
    if (Provider.of<SplashController>(Get.context!, listen: false)
            .configModel!
            .shippingMethod !=
        'sellerwise_shipping') {
      Provider.of<ShippingController>(Get.context!, listen: false)
          .getAdminShippingMethodList(Get.context!);
    }
  }

  Color _currentColor = Theme.of(Get.context!).cardColor; // Initial color
  final Duration duration = const Duration(milliseconds: 500);
  void changeColor() {
    setState(() {
      _currentColor = (_currentColor == Theme.of(Get.context!).cardColor)
          ? Theme.of(Get.context!).hintColor.withValues(alpha: 0.01)
          : Theme.of(Get.context!).cardColor;
      Future.delayed(const Duration(milliseconds: 700)).then((value) {
        reBackColor();
      });
      validated = true;
    });
  }

  void _scrollToSeller(int? index) async {
    if (index == null || index < 0 || index >= sellerKeys.length) return;

    // Wait for a frame to ensure layout is ready
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted || index >= sellerKeys.length) return;

    final targetContext = sellerKeys[index].currentContext;
    if (targetContext == null || !targetContext.mounted) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      alignment: 0.1, // adjust if needed
    );
  }

  void reBackColor() {
    setState(() {
      _currentColor = (_currentColor == Theme.of(Get.context!).cardColor)
          ? Theme.of(Get.context!).hintColor.withValues(alpha: 0.01)
          : Theme.of(Get.context!).cardColor;
    });
  }

  @override
  void initState() {
    _loadData();
    singleVendor = Provider.of<SplashController>(Get.context!, listen: false)
            .configModel
            ?.businessMode ==
        "single";
    super.initState();
  }

  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashController>(builder: (context, configProvider, _) {
      return Consumer<ShippingController>(
          builder: (context, shippingController, _) {
        return Consumer<CartController>(builder: (context, cart, child) {
          final colors = AllineThemeColors.of(context);
          double amount = 0.0;
          double shippingAmount = 0.0;
          double discount = 0.0;
          double tax = 0.0;
          int totalQuantity = 0;
          bool onlyDigital = true;
          List<CartModel> cartList = [];
          cartList.addAll(cart.cartList);
          bool isItemChecked = false;
          int totalItemCheckedCount = 0;

          for (CartModel cart in cartList) {
            if (cart.productType == "physical" && cart.isChecked!) {
              onlyDigital = false;
            }
          }

          List<String?> orderTypeShipping = [];
          List<String?> sellerList = [];
          List<List<String>> productType = [];
          List<CartModel> sellerGroupList = [];
          List<List<CartModel>> cartProductList = [];
          List<List<int>> cartProductIndexList = [];

          for (CartModel cart in cartList) {
            if (cart.isChecked! && !isItemChecked) {
              isItemChecked = true;
            }
            if (!sellerList.contains(cart.cartGroupId)) {
              sellerList.add(cart.cartGroupId);
              cart.isGroupChecked = false;
              sellerGroupList.add(cart);
            }
            if (cart.isChecked ?? false) {
              totalItemCheckedCount += 1;
            }
          }

          for (CartModel? seller in sellerGroupList) {
            List<CartModel> cartLists = [];
            List<int> indexList = [];
            List<String> productTypeList = [];
            bool isSellerChecked = true;
            for (CartModel cart in cartList) {
              if (seller?.cartGroupId == cart.cartGroupId) {
                cartLists.add(cart);
                indexList.add(cartList.indexOf(cart));
                productTypeList.add(cart.productType!);
                if (!cart.isChecked!) {
                  isSellerChecked = false;
                } else if (cart.isChecked!) {
                  seller?.isGroupItemChecked = true;
                }
              }
            }

            cartProductList.add(cartLists);
            productType.add(productTypeList);
            cartProductIndexList.add(indexList);
            if (isSellerChecked) {
              seller?.isGroupChecked = true;
            }
          }

          double freeDeliveryAmountDiscount = 0;
          for (var seller in sellerGroupList) {
            if (seller.freeDeliveryOrderAmount?.status == 1 &&
                seller.isGroupItemChecked!) {
              freeDeliveryAmountDiscount +=
                  seller.freeDeliveryOrderAmount!.shippingCostSaved!;
            }
            if (seller.shippingType == 'order_wise') {
              orderTypeShipping.add(seller.shippingType);
            }
          }

          if (cart.getData &&
              configProvider.configModel!.shippingMethod ==
                  'sellerwise_shipping') {
            shippingController.getShippingMethod(context, cartProductList);
          }

          for (int i = 0; i < cart.cartList.length; i++) {
            if (cart.cartList[i].isChecked!) {
              totalQuantity += cart.cartList[i].quantity!;
              amount += (cart.cartList[i].price! - cart.cartList[i].discount!) *
                  cart.cartList[i].quantity!;
              discount +=
                  cart.cartList[i].discount! * cart.cartList[i].quantity!;
              if (Provider.of<SplashController>(Get.context!, listen: false)
                      .configModel
                      ?.systemTaxIncludeStatus !=
                  1) {
                tax = CartHelper().calculateVatTax(cartList);
              }
            }
          }
          for (int i = 0;
              i < shippingController.chosenShippingList.length;
              i++) {
            if (shippingController.chosenShippingList[i].isCheckItemExist ==
                    1 &&
                !onlyDigital) {
              shippingAmount +=
                  shippingController.chosenShippingList[i].shippingCost!;
            }
          }

          for (int j = 0; j < cartList.length; j++) {
            if (cartList[j].isChecked!) {
              shippingAmount += cart.cartList[j].shippingCost ?? 0;
            }
          }

          sellerKeys.clear();
          for (int i = 0; i < sellerList.length; i++) {
            sellerKeys.add(GlobalKey());
          }

          final requiredMinOrderQtyCart = _getRequiredMinOrderQtyCartModel(
              sellerGroupList, cartProductList);
          final requiredShippingCartModel =
              _getRequiredShippingCartModel(sellerGroupList, cartProductList);
          final requiredMinOrderAmountCart =
              _getRequiredMinOrderAmountCartModel(
                  sellerGroupList, cartProductList);

          void navigateToCheckout({double? selectedShippingCost}) {
            if (_checkoutInProgress) return;
            int sellerGroupLenght = 0;
            int physicalSellerGroupLength = 0;

            for (int sellerIndex = 0;
                sellerIndex < sellerGroupList.length;
                sellerIndex++) {
              if (sellerGroupList[sellerIndex].isGroupItemChecked!) {
                sellerGroupLenght += 1;
              }

              bool hasSelectedPhysicalProduct = false;
              for (CartModel sellerCart in cartProductList[sellerIndex]) {
                if ((sellerCart.isChecked ?? false) &&
                    sellerCart.productType == 'physical') {
                  hasSelectedPhysicalProduct = true;
                  break;
                }
              }

              if (hasSelectedPhysicalProduct) {
                physicalSellerGroupLength += 1;
              }
            }

            final rawShippingFee = selectedShippingCost ?? shippingAmount;
            final double checkoutShippingFee =
                rawShippingFee > freeDeliveryAmountDiscount
                    ? rawShippingFee - freeDeliveryAmountDiscount
                    : 0;

            setState(() => _checkoutInProgress = true);
            RouterHelper.getCheckoutScreenRoute(
              action: RouteAction.push,
              cartList: cartList,
              fromProductDetails: false,
              totalOrderAmount: amount,
              shippingFee: checkoutShippingFee,
              discount: discount,
              tax: tax,
              sellerId: null,
              onlyDigital: sellerGroupLenght != physicalSellerGroupLength,
              hasPhysical: physicalSellerGroupLength > 0,
              quantity: totalQuantity,
            );
            Future<void>.delayed(const Duration(milliseconds: 800), () {
              if (mounted) setState(() => _checkoutInProgress = false);
            });
          }

          return Scaffold(
            backgroundColor: colors.background,
            bottomNavigationBar: (!cart.cartLoading && cartList.isNotEmpty)
                ? Consumer<SplashController>(
                    builder: (context, configProvider, _) {
                    return Container(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          10,
                          16,
                          10 +
                              (widget.fromDashboard
                                  ? 0
                                  : MediaQuery.paddingOf(context).bottom),
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border(top: BorderSide(color: colors.border)),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.transparent
                                    : colors.textPrimary.withValues(alpha: .07),
                                offset: Offset(0, -4),
                                blurRadius: 14)
                          ],
                        ),
                        child: cartList.isNotEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeSmall),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Text(
                                                '${getTranslated('total_price', context)}  ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        color: colors
                                                            .textSecondary,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                            if (Provider.of<SplashController>(
                                                        Get.context!,
                                                        listen: false)
                                                    .configModel
                                                    ?.systemTaxIncludeStatus ==
                                                1)
                                              Text(
                                                  '${getTranslated('inc_vat_tax', context)}',
                                                  style: titilliumSemiBold
                                                      .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor)),
                                          ]),
                                          Text(
                                              PriceConverter.convertPrice(
                                                  context,
                                                  amount +
                                                      tax +
                                                      shippingAmount -
                                                      freeDeliveryAmountDiscount),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  )),
                                        ]),
                                  ),
                                  Row(
                                    children: [
                                      Stack(children: [
                                        Padding(
                                          padding: EdgeInsetsGeometry.only(
                                              right:
                                                  Dimensions.paddingSizeSmall,
                                              top: Dimensions.paddingSizeSmall,
                                              bottom:
                                                  Dimensions.paddingSizeSmall),
                                          child: CustomAssetImageWidget(
                                            Images.cartBox,
                                            height: 35,
                                            width: 35,
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 5,
                                          child: Container(
                                            padding: EdgeInsetsGeometry.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2,
                                                  color: Theme.of(context)
                                                      .cardColor),
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            child: Text(
                                                totalItemCheckedCount
                                                    .toString(),
                                                style: titleRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    fontSize: Dimensions
                                                        .fontSizeSmall)),
                                          ),
                                        ),
                                      ]),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            bool hasNull = false;
                                            bool minimum = false;
                                            bool stockOutProduct = false;
                                            bool closeShop = false;
                                            double total = 0;

                                            if (configProvider.configModel!
                                                    .shippingMethod ==
                                                'sellerwise_shipping') {
                                              for (int index = 0;
                                                  index <
                                                      sellerGroupList.length;
                                                  index++) {
                                                bool hasPhysical = false;
                                                for (CartModel cart
                                                    in cartProductList[index]) {
                                                  if (cart.productType ==
                                                      'physical') {
                                                    hasPhysical = true;
                                                    break;
                                                  }
                                                }

                                                final currentShippingList =
                                                    shippingController
                                                        .shippingList;
                                                if (hasPhysical &&
                                                    sellerGroupList[index]
                                                        .isGroupItemChecked! &&
                                                    sellerGroupList[index]
                                                            .shippingType ==
                                                        'order_wise' &&
                                                    (currentShippingList ==
                                                            null ||
                                                        index >=
                                                            currentShippingList
                                                                .length ||
                                                        currentShippingList[
                                                                    index]
                                                                .shippingIndex ==
                                                            -1)) {
                                                  hasNull = true;
                                                  break;
                                                }
                                              }
                                            }

                                            for (int index = 0;
                                                index < sellerGroupList.length;
                                                index++) {
                                              total = 0;
                                              for (CartModel cart
                                                  in cartProductList[index]) {
                                                if (cart.isChecked ?? false) {
                                                  total += (cart.price! -
                                                          cart.discount!) *
                                                      cart.quantity!;
                                                }
                                              }
                                              final minimumOrderAmount =
                                                  sellerGroupList[index]
                                                          .minimumOrderAmountInfo ??
                                                      0;
                                              log("===Here===>$total======$minimumOrderAmount>");
                                              if (total < minimumOrderAmount) {
                                                minimum = true;
                                              }
                                            }

                                            for (int index = 0;
                                                index < sellerGroupList.length;
                                                index++) {
                                              for (CartModel cart
                                                  in cartProductList[index]) {
                                                final availableStock = cart
                                                        .productInfo
                                                        ?.totalCurrentStock ??
                                                    cart.maxQuantity ??
                                                    0;
                                                if (cart.isChecked == true &&
                                                    (cart.quantity ?? 0) >
                                                        availableStock &&
                                                    cart.productType ==
                                                        "physical") {
                                                  stockOutProduct = true;
                                                  break;
                                                }
                                              }
                                            }

                                            for (int index = 0;
                                                index < sellerGroupList.length;
                                                index++) {
                                              if (sellerGroupList[index]
                                                      .shop
                                                      ?.vacationEndDate !=
                                                  null) {
                                                bool vacationIsOn =
                                                    ShopHelper.isVacationActive(
                                                  context,
                                                  startDate:
                                                      sellerGroupList[index]
                                                          .shop
                                                          ?.vacationStartDate,
                                                  endDate:
                                                      sellerGroupList[index]
                                                          .shop
                                                          ?.vacationEndDate,
                                                  vacationDurationType:
                                                      sellerGroupList[index]
                                                          .shop
                                                          ?.vacationDurationType,
                                                  vacationStatus:
                                                      sellerGroupList[index]
                                                          .shop
                                                          ?.vacationStatus,
                                                  isInHouseSeller:
                                                      sellerGroupList[index]
                                                              .shop
                                                              ?.id ==
                                                          0,
                                                );

                                                if ((vacationIsOn ||
                                                        (sellerGroupList[index]
                                                                .shop
                                                                ?.temporaryClose ??
                                                            false)) &&
                                                    (sellerGroupList[index]
                                                            .isGroupItemChecked ??
                                                        false)) {
                                                  closeShop = true;
                                                  break;
                                                }
                                              }
                                            }

                                            if (configProvider.configModel
                                                        ?.guestCheckOut ==
                                                    0 &&
                                                !Provider.of<AuthController>(
                                                        context,
                                                        listen: false)
                                                    .isLoggedIn()) {
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (_) =>
                                                      NotLoggedInBottomSheetWidget(
                                                          fromPage: widget
                                                                  .fromDashboard
                                                              ? '${RouterHelper.dashboardScreen}?page=cart'
                                                              : RouterHelper
                                                                  .cartScreen,
                                                          onLoginSuccess: () {
                                                            RouterHelper.getDashboardRoute(
                                                                action: RouteAction
                                                                    .pushReplacement,
                                                                page: 'cart');
                                                            Provider.of<CartController>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .mergeGuestCart();
                                                          }));
                                            } else if (cart.cartList.isEmpty) {
                                              showCustomSnackBarWidget(
                                                  getTranslated(
                                                      'select_at_least_one_product',
                                                      context),
                                                  Get.context!,
                                                  snackBarType:
                                                      SnackBarType.warning);
                                            } else if (stockOutProduct) {
                                              showCustomSnackBarWidget(
                                                  getTranslated(
                                                      'stock_out_product_in_your_cart',
                                                      context),
                                                  Get.context!,
                                                  snackBarType:
                                                      SnackBarType.warning);
                                            } else if (closeShop) {
                                              showCustomSnackBarWidget(
                                                  getTranslated(
                                                      'unavailable_shop_product_in_your_cart',
                                                      context),
                                                  Get.context!,
                                                  snackBarType:
                                                      SnackBarType.warning);
                                            } else if (minimum) {
                                              showCustomSnackBarWidget(
                                                  '${getTranslated('minimum_order_amount', Get.context!)} ${PriceConverter.convertPrice(Get.context!, requiredMinOrderAmountCart?.sellerCart.minimumOrderAmountInfo)} ${getTranslated('for', Get.context!)}  ${requiredMinOrderAmountCart?.sellerCart.sellerIs == 'admin' ? Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name : requiredShippingCartModel?.sellerCart.shop?.name}',
                                                  Get.context!,
                                                  snackBarType:
                                                      SnackBarType.warning);
                                              _scrollToSeller(
                                                  requiredMinOrderAmountCart
                                                      ?.sellerIndex);
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 900));
                                              changeColor();
                                            } else if (!isItemChecked) {
                                              showCustomSnackBarWidget(
                                                  getTranslated(
                                                      'please_select_items',
                                                      context),
                                                  Get.context!,
                                                  snackBarType:
                                                      SnackBarType.warning);
                                            } else if (requiredMinOrderQtyCart !=
                                                null) {
                                              showCustomSnackBarWidget(
                                                  '${getTranslated('to_order', Get.context!)} ${requiredMinOrderQtyCart.productCart.name} ${getTranslated('min_order_quantity_is', Get.context!)} ${requiredMinOrderQtyCart.productCart.productInfo?.minimumOrderQty}',
                                                  Get.context!,
                                                  snackBarType:
                                                      SnackBarType.warning);
                                              _scrollToSeller(
                                                  requiredMinOrderQtyCart
                                                      .sellerIndex);
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 900));
                                              changeColor();
                                            } else if (hasNull &&
                                                configProvider.configModel!
                                                        .shippingMethod ==
                                                    'sellerwise_shipping' &&
                                                !onlyDigital) {
                                              final defaultShippingCost =
                                                  await shippingController
                                                      .ensureDefaultShippingMethods(
                                                context,
                                                sellerGroupList,
                                                cartProductList,
                                              );
                                              if (!context.mounted) return;

                                              if (defaultShippingCost == null) {
                                                showCustomSnackBarWidget(
                                                  'تعذر تحديد رسوم التوصيل لهذا الطلب. تأكد من أن المتجر يوفّر خدمة توصيل.',
                                                  context,
                                                  snackBarType:
                                                      SnackBarType.warning,
                                                );
                                                _scrollToSeller(
                                                    requiredShippingCartModel
                                                        ?.sellerIndex);
                                                return;
                                              }

                                              final productShippingCost =
                                                  cartList
                                                      .where((cartItem) =>
                                                          cartItem.isChecked ==
                                                          true)
                                                      .fold<double>(
                                                        0,
                                                        (sum, cartItem) =>
                                                            sum +
                                                            (cartItem
                                                                    .shippingCost ??
                                                                0),
                                                      );
                                              navigateToCheckout(
                                                selectedShippingCost:
                                                    productShippingCost +
                                                        defaultShippingCost,
                                              );
                                            } else {
                                              navigateToCheckout();
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                    vertical: Dimensions
                                                        .fontSizeSmall),
                                                child: _checkoutInProgress
                                                    ? const SizedBox(
                                                        width: 22,
                                                        height: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2.3,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'متابعة إلى الدفع',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'AllineTajawal',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.white)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox());
                  })
                : null,
            appBar: AppBar(
              leading: widget.showBackButton
                  ? IconButton(
                      tooltip: 'رجوع',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    )
                  : null,
              title: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('السلة', style: Theme.of(context).textTheme.titleLarge),
                if (cartList.isNotEmpty)
                  Text('${cartList.length} منتجات',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colors.textSecondary)),
              ]),
            ),
            body: Column(children: [
              cart.cartLoading
                  ? const Expanded(child: CartPageShimmerWidget())
                  : sellerList.isNotEmpty
                      ? Expanded(
                          child: Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  await Provider.of<CartController>(context,
                                          listen: false)
                                      .getCartData(context);
                                },
                                child: ListView(
                                  children: [
                                    _CartSummaryIntro(
                                      itemCount: cartList.length,
                                      storeCount: sellerList.length,
                                      selectedCount: totalItemCheckedCount,
                                    ),
                                    const _CartDeliveryAddressCard(),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(
                                          bottom: Dimensions.paddingSizeSmall),
                                      itemCount: sellerList.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall);
                                      },
                                      itemBuilder: (context, index) {
                                        bool hasPhysical = false;
                                        double totalCost = 0;
                                        bool shopClose = false;
                                        for (CartModel cart
                                            in cartProductList[index]) {
                                          if (cart.isChecked ?? false) {
                                            totalCost +=
                                                (cart.price! - cart.discount!) *
                                                    cart.quantity!;
                                          }
                                        }

                                        for (CartModel cart
                                            in cartProductList[index]) {
                                          if (cart.productType == 'physical' &&
                                              cart.isChecked!) {
                                            hasPhysical = true;
                                            break;
                                          }
                                        }

                                        if (sellerGroupList[index]
                                                .shop
                                                ?.vacationEndDate !=
                                            null) {
                                          bool vacationIsOn =
                                              ShopHelper.isVacationActive(
                                            context,
                                            startDate: sellerGroupList[index]
                                                .shop
                                                ?.vacationStartDate,
                                            endDate: sellerGroupList[index]
                                                .shop
                                                ?.vacationEndDate,
                                            vacationDurationType:
                                                sellerGroupList[index]
                                                    .shop
                                                    ?.vacationDurationType,
                                            vacationStatus:
                                                sellerGroupList[index]
                                                    .shop
                                                    ?.vacationStatus,
                                            isInHouseSeller:
                                                sellerGroupList[index]
                                                        .shop
                                                        ?.id ==
                                                    0,
                                          );

                                          if (vacationIsOn ||
                                              (sellerGroupList[index]
                                                      .shop
                                                      ?.temporaryClose ??
                                                  false)) {
                                            shopClose = true;
                                          }
                                        }

                                        // print('---Shipping-${sellerGroupList[index].shop?.name}---${
                                        //     (configProvider.configModel!.shippingMethod == 'sellerwise_shipping' &&
                                        //         sellerGroupList[index].shippingType == 'order_wise' &&
                                        //         Provider.of<ShippingController>(context, listen: false).shippingList != null &&  Provider.of<ShippingController>(context, listen: false).shippingList!.isNotEmpty &&
                                        //         Provider.of<ShippingController>(context, listen: false).shippingList?.length == index+1 &&
                                        //         Provider.of<ShippingController>(context, listen: false).shippingList?[index].shippingIndex == -1 && sellerGroupList[index].isGroupItemChecked == true)
                                        //}---');

                                        bool showColor = ((sellerGroupList[index].minimumOrderAmountInfo ?? 0) >
                                                totalCost) ||
                                            (configProvider.configModel!.shippingMethod ==
                                                    'sellerwise_shipping' &&
                                                sellerGroupList[index].shippingType ==
                                                    'order_wise' &&
                                                Provider.of<ShippingController>(context, listen: false)
                                                        .shippingList !=
                                                    null &&
                                                Provider.of<ShippingController>(context,
                                                        listen: false)
                                                    .shippingList!
                                                    .isNotEmpty &&
                                                requiredShippingCartModel?.sellerIndex ==
                                                    index &&
                                                Provider.of<ShippingController>(
                                                            context,
                                                            listen: false)
                                                        .shippingList?[index]
                                                        .shippingIndex ==
                                                    -1 &&
                                                sellerGroupList[index].isGroupItemChecked == true);

                                        bool isNotValidated = ((sellerGroupList[index]
                                                        .minimumOrderAmountInfo ??
                                                    0) >
                                                totalCost) ||
                                            (configProvider.configModel!
                                                        .shippingMethod ==
                                                    'sellerwise_shipping' &&
                                                sellerGroupList[index].shippingType ==
                                                    'order_wise' &&
                                                Provider.of<ShippingController>(context, listen: false)
                                                        .shippingList !=
                                                    null &&
                                                Provider.of<ShippingController>(context, listen: false)
                                                    .shippingList!
                                                    .isNotEmpty &&
                                                Provider.of<ShippingController>(context,
                                                            listen: false)
                                                        .shippingList?[index]
                                                        .shippingIndex ==
                                                    -1 &&
                                                sellerGroupList[index].isGroupItemChecked == true);

                                        return AnimatedContainer(
                                          key: sellerKeys[index],
                                          duration: duration,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: showColor
                                                ? _currentColor
                                                : index.floor().isOdd
                                                    ? Theme.of(context)
                                                        .cardColor
                                                    : Theme.of(context)
                                                        .cardColor,
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Color(0x0A032C75),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 12)
                                            ],
                                            border: Border.all(
                                                color: validated &&
                                                        isNotValidated
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                    : const Color(0xFFE1E8F2),
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions
                                                    .paddingSizeSmall),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  sellerGroupList[index]
                                                          .shopInfo!
                                                          .isNotEmpty
                                                      ? ColoredBox(
                                                          color: Colors
                                                              .transparent,
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                top: Dimensions
                                                                    .paddingSizeSmall),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                                                        child: Column(
                                                                          children: [
                                                                            Row(children: [
                                                                              SizedBox(
                                                                                height: 24,
                                                                                width: 30,
                                                                                child: Checkbox(
                                                                                  visualDensity: VisualDensity.compact,
                                                                                  side: WidgetStateBorderSide.resolveWith((states) => BorderSide(width: 2, color: Theme.of(context).hintColor.withValues(alpha: 0.50))),
                                                                                  checkColor: Colors.white,
                                                                                  value: sellerGroupList[index].isGroupChecked,
                                                                                  onChanged: (bool? value) async {
                                                                                    List<int> ids = [];
                                                                                    for (CartModel cart in cartProductList[index]) {
                                                                                      ids.add(cart.id!);
                                                                                    }

                                                                                    showDialog(context: context, builder: (ctx) => const CustomLoaderWidget());
                                                                                    await cart.addRemoveCartSelectedItem(ids, sellerGroupList[index].isGroupChecked! ? false : true);

                                                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                                      Navigator.of(Get.context!).pop();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              Flexible(
                                                                                child: InkWell(onTap: () => _storeScreenRouteCall(sellerGroupList[index]), child: Text(sellerGroupList[index].shopInfo!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start, style: textBold.copyWith(fontWeight: FontWeight.w500, fontSize: Dimensions.fontSizeLarge, color: Provider.of<ThemeController>(context, listen: false).darkTheme ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color))),
                                                                              ),
                                                                              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall), child: Text('(${cartProductList[index].length})', style: textBold.copyWith(color: Provider.of<ThemeController>(context, listen: false).darkTheme ? Theme.of(context).hintColor : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge))),
                                                                              if (shopClose)
                                                                                JustTheTooltip(
                                                                                  backgroundColor: Colors.black87,
                                                                                  controller: tooltipController,
                                                                                  preferredDirection: AxisDirection.down,
                                                                                  tailLength: 10,
                                                                                  tailBaseWidth: 20,
                                                                                  content: Container(width: 150, padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text(getTranslated('store_is_closed', context)!, style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault))),
                                                                                  child: InkWell(
                                                                                    onTap: () => tooltipController.showTooltip(),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                                                                      child: SizedBox(
                                                                                          width: 30,
                                                                                          child: Image.asset(
                                                                                            Images.warning,
                                                                                            color: Theme.of(context).colorScheme.error,
                                                                                          )),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                            ]),
                                                                          ],
                                                                        ))),
                                                                const SizedBox(),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                  if (((sellerGroupList[index]
                                                                  .minimumOrderAmountInfo ??
                                                              0) >
                                                          totalCost) ||
                                                      (configProvider
                                                                  .configModel!
                                                                  .shippingMethod ==
                                                              'sellerwise_shipping' &&
                                                          sellerGroupList[index]
                                                                  .shippingType ==
                                                              'order_wise' &&
                                                          hasPhysical))
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: Dimensions
                                                              .paddingSizeDefault,
                                                          right: Dimensions
                                                              .paddingSizeDefault,
                                                          top: Dimensions
                                                              .paddingSizeSmall),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (configProvider
                                                                      .configModel!
                                                                      .shippingMethod ==
                                                                  'sellerwise_shipping' &&
                                                              sellerGroupList[
                                                                          index]
                                                                      .shippingType ==
                                                                  'order_wise' &&
                                                              hasPhysical)
                                                            Container(
                                                              child: ((shippingController
                                                                                  .shippingList !=
                                                                              null &&
                                                                          shippingController
                                                                              .shippingList!
                                                                              .isNotEmpty &&
                                                                          shippingController.shippingList![index].shippingMethodList !=
                                                                              null &&
                                                                          shippingController.shippingList![index].shippingIndex !=
                                                                              -1) &&
                                                                      shippingController
                                                                          .chosenShippingList
                                                                          .isNotEmpty)
                                                                  ? Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                (shippingController.shippingList == null || shippingController.shippingList![index].shippingMethodList == null || shippingController.chosenShippingList.isEmpty || shippingController.shippingList![index].shippingIndex == -1) ? '' : '${getTranslated('shipping_cost', context) ?? ''} : ',
                                                                                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                                                              ),
                                                                              Text((shippingController.shippingList == null || shippingController.shippingList![index].shippingMethodList == null || shippingController.chosenShippingList.isEmpty || shippingController.shippingList![index].shippingIndex == -1) ? '' : PriceConverter.convertPrice(context, shippingController.shippingList![index].shippingMethodList![shippingController.shippingList![index].shippingIndex!].cost), style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              width: Dimensions.paddingSizeSmall),
                                                                          Row(children: [
                                                                            Text((shippingController.shippingList == null || shippingController.shippingList![index].shippingMethodList == null || shippingController.chosenShippingList.isEmpty || shippingController.shippingList![index].shippingIndex == -1) ? '' : '${getTranslated('shipping_time', context) ?? ''} : ',
                                                                                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall)),
                                                                            Text(
                                                                                (shippingController.shippingList == null || shippingController.shippingList![index].shippingMethodList == null || shippingController.chosenShippingList.isEmpty || shippingController.shippingList![index].shippingIndex == -1)
                                                                                    ? ''
                                                                                    : '${shippingController.shippingList![index].shippingMethodList![shippingController.shippingList![index].shippingIndex!].duration.toString()} '
                                                                                        '',
                                                                                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textAlign: TextAlign.end)
                                                                          ]),
                                                                        ])
                                                                  : const SizedBox(),
                                                            ),

                                                          // if(configProvider.configModel!.shippingMethod == 'sellerwise_shipping' && sellerGroupList[index].shippingType == 'order_wise' && hasPhysical)
                                                          //   SizedBox(height: Dimensions.paddingSizeSmall,),

                                                          if ((sellerGroupList[
                                                                          index]
                                                                      .minimumOrderAmountInfo ??
                                                                  0) >
                                                              totalCost)
                                                            Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        0),
                                                                child: Text(
                                                                    '${getTranslated('minimum_order_amount_is', context)} '
                                                                    '${PriceConverter.convertPrice(context, sellerGroupList[index].minimumOrderAmountInfo)}',
                                                                    style: textRegular.copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .error,
                                                                        fontSize:
                                                                            12))),
                                                        ],
                                                      ),
                                                    ),
                                                  Container(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          bottom: Dimensions
                                                              .paddingSizeDefault),
                                                      // decoration: BoxDecoration(color: Theme.of(context).cardColor),
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(0),
                                                            itemCount:
                                                                cartProductList[
                                                                        index]
                                                                    .length,
                                                            itemBuilder:
                                                                (context, i) {
                                                              return CartWidget(
                                                                highLightColor:
                                                                    _currentColor,
                                                                cartModel:
                                                                    cartProductList[
                                                                        index][i],
                                                                index:
                                                                    cartProductIndexList[
                                                                        index][i],
                                                                fromCheckout: widget
                                                                    .fromCheckout,
                                                                isValidate:
                                                                    validated,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      )),
                                                  if (sellerGroupList[index]
                                                              .freeDeliveryOrderAmount
                                                              ?.status ==
                                                          1 &&
                                                      hasPhysical &&
                                                      sellerGroupList[index]
                                                          .isGroupItemChecked! &&
                                                      !singleVendor)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                        Dimensions
                                                            .paddingSizeDefault,
                                                        0,
                                                        Dimensions
                                                            .paddingSizeDefault,
                                                        0,
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .paddingSizeExtraSmall),
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha:
                                                                        0.03),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    bottom: Dimensions
                                                                        .paddingSizeSmall,
                                                                    left: Dimensions
                                                                        .paddingSizeDefault,
                                                                    right: Dimensions
                                                                        .paddingSizeDefault,
                                                                    top: Dimensions
                                                                        .paddingSizeSmall),
                                                                child: Row(
                                                                  children: [
                                                                    if (sellerGroupList[index]
                                                                            .freeDeliveryOrderAmount!
                                                                            .amountNeed! >
                                                                        0)
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                Dimensions.paddingSizeExtraSmall),
                                                                        child: Text(
                                                                            PriceConverter.convertPrice(context,
                                                                                sellerGroupList[index].freeDeliveryOrderAmount!.amountNeed!),
                                                                            style: textMedium.copyWith(color: Theme.of(context).primaryColor)),
                                                                      ),
                                                                    sellerGroupList[index].freeDeliveryOrderAmount!.percentage! <
                                                                            100
                                                                        ? Text(
                                                                            '${getTranslated('add_more_for_free_delivery', context)}',
                                                                            style:
                                                                                textMedium.copyWith(color: Theme.of(context).textTheme.titleMedium?.color))
                                                                        : Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                                                            child:
                                                                                Text('${getTranslated('you_got_free_delivery', context)}', style: textBold.copyWith(color: Theme.of(context).textTheme.titleMedium?.color)),
                                                                          )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                                child:
                                                                    CircularProgressWithLogo(
                                                                  targetProgress:
                                                                      sellerGroupList[index]
                                                                              .freeDeliveryOrderAmount!
                                                                              .percentage! /
                                                                          100,
                                                                  logoAsset: CustomAssetImageWidget(
                                                                      Images
                                                                          .freeDeliveryIcon,
                                                                      color: sellerGroupList[index].freeDeliveryOrderAmount!.percentage! <
                                                                              100
                                                                          ? Theme.of(context)
                                                                              .colorScheme
                                                                              .onTertiaryContainer
                                                                          : Theme.of(context)
                                                                              .cardColor),
                                                                  progressColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onTertiaryContainer,
                                                                  size: 30,
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ]),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(),
                                    _CartOrderSummary(
                                      productsSubtotal: amount + discount,
                                      discount: discount,
                                      shipping: shippingAmount -
                                          freeDeliveryAmountDiscount,
                                      tax: tax,
                                      total: amount +
                                          tax +
                                          shippingAmount -
                                          freeDeliveryAmountDiscount,
                                      deliveryCalculated: shippingAmount > 0 ||
                                          freeDeliveryAmountDiscount > 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (sellerGroupList[0]
                                        .freeDeliveryOrderAmount
                                        ?.status ==
                                    1 &&
                                CartHelper().hasPhysical(cartProductList) &&
                                sellerGroupList[0].isGroupItemChecked! &&
                                singleVendor)
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeSmall,
                                  Dimensions.paddingSizeDefault,
                                  0,
                                ),
                                color: Theme.of(context).cardColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.paddingSizeExtraSmall),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.paddingSizeExtraSmall),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  Dimensions.paddingSizeSmall,
                                              left:
                                                  Dimensions.paddingSizeDefault,
                                              right:
                                                  Dimensions.paddingSizeDefault,
                                              top: Dimensions.paddingSizeSmall),
                                          child: Row(
                                            children: [
                                              if (sellerGroupList[0]
                                                      .freeDeliveryOrderAmount!
                                                      .amountNeed! >
                                                  0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  child: Text(
                                                      PriceConverter.convertPrice(
                                                          context,
                                                          sellerGroupList[0]
                                                              .freeDeliveryOrderAmount!
                                                              .amountNeed!),
                                                      style: textMedium.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                                ),
                                              sellerGroupList[0]
                                                          .freeDeliveryOrderAmount!
                                                          .percentage! <
                                                      100
                                                  ? Text(
                                                      '${getTranslated('add_more_for_free_delivery', context)}',
                                                      style:
                                                          textMedium.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.color))
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      child: Text(
                                                          '${getTranslated('you_got_free_delivery', context)}',
                                                          style: textBold.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.color)),
                                                    )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall),
                                          child: CircularProgressWithLogo(
                                            targetProgress: sellerGroupList[0]
                                                    .freeDeliveryOrderAmount!
                                                    .percentage! /
                                                100,
                                            logoAsset: CustomAssetImageWidget(
                                                Images.freeDeliveryIcon,
                                                color: sellerGroupList[0]
                                                            .freeDeliveryOrderAmount!
                                                            .percentage! <
                                                        100
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onTertiaryContainer
                                                    : Theme.of(context)
                                                        .cardColor),
                                            progressColor: Theme.of(context)
                                                .colorScheme
                                                .onTertiaryContainer,
                                            size: 30,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ))
                      : cart.cartLoadFailed
                          ? Expanded(
                              child: AllineErrorState(
                                title: 'تعذر تحميل السلة',
                                message:
                                    'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
                                onRetry: () => cart.getCartData(context),
                              ),
                            )
                          : Expanded(
                              child: AllineEmptyState(
                                icon: Icons.shopping_cart_outlined,
                                title: 'سلتك فارغة',
                                message:
                                    'أضف المنتجات التي تعجبك إلى سلتك وابدأ التسوق.',
                                actionLabel: 'ابدأ التسوق',
                                onAction: () => RouterHelper.getDashboardRoute(
                                  action: RouteAction.pushReplacement,
                                  page: 'home',
                                ),
                              ),
                            ),
            ]),
          );
        });
      });
    });
  }

  ({CartModel sellerCart, int? sellerIndex})? _getRequiredShippingCartModel(
    List<CartModel> sellerGroupList,
    List<List<CartModel>> cartProductList,
  ) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;
    if (configModel!.shippingMethod == 'sellerwise_shipping') {
      for (int index = 0; index < sellerGroupList.length; index++) {
        bool hasPhysical = false;
        for (CartModel cart in cartProductList[index]) {
          if (cart.productType == 'physical') {
            hasPhysical = true;
            break;
          }
        }

        if (hasPhysical &&
            sellerGroupList[index].isGroupItemChecked! &&
            sellerGroupList[index].shippingType == 'order_wise' &&
            Provider.of<ShippingController>(context, listen: false)
                    .shippingList !=
                null &&
            Provider.of<ShippingController>(context, listen: false)
                .shippingList!
                .isNotEmpty &&
            Provider.of<ShippingController>(context, listen: false)
                    .shippingList![index]
                    .shippingIndex ==
                -1 &&
            sellerGroupList[index].isGroupItemChecked!) {
          // it breaks here ovider.of<ShippingController>(context, listen: false).shippingList![index].

          return (sellerCart: sellerGroupList[index], sellerIndex: index);
        }
      }
    }
    return null;
  }

  ({CartModel productCart, CartModel sellerCart, int? sellerIndex})?
      _getRequiredMinOrderQtyCartModel(
    List<CartModel> sellerGroupList,
    List<List<CartModel>> cartProductList,
  ) {
    for (int index = 0; index < sellerGroupList.length; index++) {
      for (CartModel cart in cartProductList[index]) {
        if (cart.isChecked == true &&
            cart.quantity! < (cart.productInfo?.minimumOrderQty ?? 1)) {
          return (
            productCart: cart,
            sellerCart: sellerGroupList[index],
            sellerIndex: index
          );
        }
      }
    }
    return null;
  }

  ({CartModel productCart, CartModel sellerCart, int sellerIndex})?
      _getRequiredMinOrderAmountCartModel(
    List<CartModel> sellerGroupList,
    List<List<CartModel>> cartProductList,
  ) {
    double total;
    for (int index = 0; index < sellerGroupList.length; index++) {
      total = 0;
      for (CartModel cart in cartProductList[index]) {
        if (cart.isChecked ?? false) {
          total += (cart.price! - cart.discount!) * cart.quantity!;
        }
      }
      final minimumOrderAmount =
          sellerGroupList[index].minimumOrderAmountInfo ?? 0;
      log("===Here===>$total======$minimumOrderAmount>");
      if (total < minimumOrderAmount) {
        return (
          productCart: cartProductList[index].first,
          sellerCart: sellerGroupList[index],
          sellerIndex: index
        );
      }
    }
    return null;
  }

  void _storeScreenRouteCall(CartModel sellerList) {
    if (sellerList.sellerIs == 'admin') {
      RouterHelper.getTopSellerRoute(
          action: RouteAction.push,
          sellerId: 0,
          slug: Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inHouseShop
              ?.slug,
          fromMore: false,
          temporaryClose: Provider.of<SplashController>(context, listen: false)
                  .configModel
                  ?.inhouseTemporaryClose
                  ?.status ??
              false,
          vacationStatus: Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inhouseVacationAdd
              ?.status,
          vacationEndDate: Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inhouseVacationAdd
              ?.vacationEndDate,
          vacationStartDate:
              Provider.of<SplashController>(context, listen: false)
                  .configModel
                  ?.inhouseVacationAdd
                  ?.vacationStartDate,
          vacationDurationType:
              Provider.of<SplashController>(context, listen: false)
                  .configModel
                  ?.inhouseVacationAdd
                  ?.vacationDurationType,
          name: Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inHouseShop
              ?.name,
          banner: Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inHouseShop
              ?.bannerFullUrl
              ?.path,
          image: Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inHouseShop
              ?.imageFullUrl
              ?.path);
    } else {
      RouterHelper.getTopSellerRoute(
          action: RouteAction.push,
          slug: sellerList.shop?.slug,
          sellerId: sellerList.shop?.sellerId,
          temporaryClose: sellerList.shop?.temporaryClose,
          vacationStatus: sellerList.shop?.vacationStatus,
          vacationEndDate: sellerList.shop?.vacationEndDate,
          vacationStartDate: sellerList.shop?.vacationStartDate,
          vacationDurationType: sellerList.shop?.vacationDurationType,
          name: sellerList.shop?.name,
          banner: sellerList.shop?.bannerFullUrl?.path,
          image: sellerList.shop?.imageFullUrl?.path);
    }
  }
}

class _CartSummaryIntro extends StatelessWidget {
  final int itemCount;
  final int storeCount;
  final int selectedCount;

  const _CartSummaryIntro({
    required this.itemCount,
    required this.storeCount,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) => AllineCard(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(Icons.shopping_cart_outlined,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لديك $itemCount منتجات في السلة',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(
                    '$selectedCount محدد${storeCount > 1 ? ' • سيتم تقسيم الطلب حسب $storeCount متاجر' : ''}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ]),
      );
}

class _CartDeliveryAddressCard extends StatelessWidget {
  const _CartDeliveryAddressCard();

  @override
  Widget build(BuildContext context) => Consumer<LocationController>(
        builder: (context, location, _) {
          final colors = AllineThemeColors.of(context);
          final label = location.deliveryLabel?.trim();
          return AllineCard(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عنوان التوصيل',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 3),
                    Text(
                        label?.isNotEmpty == true
                            ? label!
                            : 'لم يتم تحديد عنوان التوصيل بعد',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => RouterHelper.getLocationSetupRoute(
                    action: RouteAction.push),
                style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    foregroundColor: Theme.of(context).colorScheme.primary),
                child: Text(label?.isNotEmpty == true ? 'تغيير' : 'تحديد',
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ]),
          );
        },
      );
}

class _CartOrderSummary extends StatelessWidget {
  final double productsSubtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final bool deliveryCalculated;

  const _CartOrderSummary({
    required this.productsSubtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.deliveryCalculated,
  });

  @override
  Widget build(BuildContext context) => AllineCard(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ملخص الطلب', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          _SummaryRow(
              label: 'إجمالي المنتجات',
              value: PriceConverter.convertPrice(context, productsSubtotal)),
          if (discount > 0)
            _SummaryRow(
                label: 'الخصم',
                value: '-${PriceConverter.convertPrice(context, discount)}',
                valueColor: AllineThemeColors.of(context).success),
          _SummaryRow(
            label: 'رسوم التوصيل',
            value: deliveryCalculated
                ? (shipping <= 0
                    ? 'مجاني'
                    : PriceConverter.convertPrice(context, shipping))
                : 'تحسب عند إتمام الطلب',
          ),
          if (tax > 0)
            _SummaryRow(
                label: 'الضريبة',
                value: PriceConverter.convertPrice(context, tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _SummaryRow(
              label: 'الإجمالي',
              value: PriceConverter.convertPrice(context, total),
              emphasized: true),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10)),
            child: Text('يمكنك إضافة كوبون الخصم في خطوة الدفع التالية.',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ]),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasized;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: emphasized ? 16 : 13,
                  fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                  color: colors.textPrimary)),
        ),
        const SizedBox(width: 12),
        Text(value,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontSize: emphasized ? 18 : 13,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ??
                    (emphasized
                        ? Theme.of(context).colorScheme.primary
                        : colors.textPrimary))),
      ]),
    );
  }
}
