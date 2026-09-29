import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/checkout_condition_checkbox.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/cart_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/debounce_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/choose_payment_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/coupon_apply_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/checkout_products_summary.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/shipping_details_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/wallet_payment_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final bool fromProductDetails;
  final double totalOrderAmount;
  final double shippingFee;
  final double discount;
  final double tax;
  final int? sellerId;
  final bool onlyDigital;
  final bool hasPhysical;
  final int quantity;

  const CheckoutScreen(
      {super.key,
      required this.cartList,
      this.fromProductDetails = false,
      required this.discount,
      required this.tax,
      required this.totalOrderAmount,
      required this.shippingFee,
      this.sellerId,
      this.onlyDigital = false,
      required this.quantity,
      required this.hasPhysical});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  final FocusNode _orderNoteNode = FocusNode();
  double _order = 0;
  double _tax = 0;
  late bool _billingAddress;
  double? _couponDiscount;
  double? _referralDiscount;

  double get _payableAmount =>
      _order +
      widget.shippingFee -
      widget.discount -
      (_referralDiscount ?? 0) -
      (_couponDiscount ?? 0) +
      _tax;

  DebounceHelper debounceHelper = DebounceHelper(milliseconds: 500);
  SplashController splashController =
      Provider.of<SplashController>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    Provider.of<AddressController>(context, listen: false).getAddressList();
    Provider.of<CheckoutController>(context, listen: false)
        .getReferralAmount('0');
    Provider.of<CouponController>(context, listen: false)
        .removePrevCouponData();
    Provider.of<CartController>(context, listen: false).getCartData(context);
    Provider.of<CheckoutController>(context, listen: false)
        .resetPaymentMethod();
    if ((splashController.configModel?.cashOnDelivery ?? false) &&
        !widget.onlyDigital) {
      Provider.of<CheckoutController>(context, listen: false)
          .setOfflineChecked('cod', notify: false);
    }
    Provider.of<ShippingController>(context, listen: false)
        .getChosenShippingMethod(context);
    // The API is the source of truth for enabled local wallets.  Do not gate
    // this request behind the cached config flag: it can be stale and would
    // make a valid wallet unavailable for a whole cart.
    Provider.of<CheckoutController>(context, listen: false)
        .getOfflinePaymentList();

    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<CouponController>(context, listen: false)
          .getAvailableCouponList();
      Provider.of<WalletController>(context, listen: false)
          .getLocalWalletMethods();
    }

    if (Provider.of<CheckoutController>(context, listen: false).isAcceptTerms) {
      Provider.of<CheckoutController>(context, listen: false)
          .toggleTermsCheck(isUpdate: false);
    }

    _billingAddress = Provider.of<SplashController>(Get.context!, listen: false)
            .configModel!
            .billingInputByCustomer ==
        1;
    Provider.of<CheckoutController>(context, listen: false).clearData();

    if (splashController.configModel?.systemTaxIncludeStatus != 1) {
      _tax = widget.tax;
    }
  }

  @override
  Widget build(BuildContext context) {
    _order = widget.totalOrderAmount + widget.discount;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      bottomNavigationBar:
          Consumer<AddressController>(builder: (context, locationProvider, _) {
        return Consumer<CheckoutController>(
            builder: (context, orderProvider, child) {
          return Consumer<CouponController>(
              builder: (context, couponProvider, _) {
            if (splashController.configModel?.systemTaxIncludeStatus != 1) {
              _tax = CartHelper().calculateVatTax(
                  Provider.of<CartController>(context, listen: false).cartList);
            }
            _couponDiscount = couponProvider.discount ?? 0;
            _referralDiscount = orderProvider.referralAmount?.amount ?? 0;
            return Consumer<CartController>(
                builder: (context, cartProvider, _) {
              return Consumer<ProfileController>(
                  builder: (context, profileProvider, _) {
                final addressList = locationProvider.addressList ?? [];
                final hasDeliveryAddress = orderProvider.addressIndex != null &&
                    orderProvider.addressIndex! >= 0 &&
                    orderProvider.addressIndex! < addressList.length;
                final deliveryAddressMissing = widget.hasPhysical &&
                    locationProvider.addressList != null &&
                    !hasDeliveryAddress;
                final paymentMethodMissing = !orderProvider.isCODChecked &&
                    !orderProvider.isOfflineChecked &&
                    !orderProvider.isWalletChecked &&
                    orderProvider.selectedDigitalPaymentMethodName.isEmpty;
                final totalPayable = _payableAmount;

                return SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: const Border(
                        top: BorderSide(color: Color(0xFFE1E8F2)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF032C75).withValues(alpha: .04),
                          blurRadius: 14,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الإجمالي',
                                    style: textRegular.copyWith(
                                      fontSize: 12,
                                      color: const Color(0xFF6D85AF),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    PriceConverter.convertPrice(
                                        context, totalPayable),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textBold.copyWith(
                                      fontSize: 18,
                                      color: const Color(0xFF015FC9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: CheckoutConditionCheckBox(),
                            ),
                          ],
                        ),
                        if (deliveryAddressMissing) ...[
                          const SizedBox(height: 6),
                          _CheckoutRequirementMessage(
                            text: 'أضف عنوان التوصيل للمتابعة.',
                            icon: Icons.location_on_outlined,
                          ),
                        ],
                        if (paymentMethodMissing) ...[
                          const SizedBox(height: 6),
                          const _CheckoutRequirementMessage(
                            text: 'اختر طريقة الدفع لإتمام الطلب.',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ],
                        if (!orderProvider.isAcceptTerms) ...[
                          const SizedBox(height: 6),
                          const _CheckoutRequirementMessage(
                            text: 'الموافقة على الشروط مطلوبة للمتابعة.',
                            icon: Icons.info_outline_rounded,
                          ),
                        ],
                        const SizedBox(height: 10),
                        CustomButton(
                          isLoading: orderProvider.isLoading,
                          loadingText: 'جارٍ إرسال الطلب...',
                          onTap: (orderProvider.isLoading ||
                                  !orderProvider.isAcceptTerms)
                              ? null
                              : () async {
                                  final addressList =
                                      locationProvider.addressList ?? [];
                                  final hasDeliveryAddress =
                                      orderProvider.addressIndex != null &&
                                          orderProvider.addressIndex! >= 0 &&
                                          orderProvider.addressIndex! <
                                              addressList.length;
                                  final hasBillingAddress = orderProvider
                                              .billingAddressIndex !=
                                          null &&
                                      orderProvider.billingAddressIndex! >= 0 &&
                                      orderProvider.billingAddressIndex! <
                                          addressList.length;

                                  if (!hasDeliveryAddress &&
                                      widget.hasPhysical) {
                                    RouterHelper.getSavedAddressListRoute(
                                        fromGuest: !Provider.of<AuthController>(
                                                context,
                                                listen: false)
                                            .isLoggedIn());
                                    showCustomSnackBarWidget(
                                        getTranslated(
                                            'select_a_shipping_address',
                                            context),
                                        Get.context!,
                                        snackBarType: SnackBarType.warning);
                                  } else if ((!hasBillingAddress &&
                                      !widget.hasPhysical &&
                                      !_billingAddress)) {
                                    showCustomSnackBarWidget(
                                        getTranslated(
                                            'you_cant_place_order_of_digital_product_without_billing_address',
                                            context),
                                        Get.context!,
                                        snackBarType: SnackBarType.warning);
                                  } else if ((!hasBillingAddress &&
                                          !widget.hasPhysical &&
                                          !orderProvider.sameAsBilling &&
                                          _billingAddress) ||
                                      (!hasBillingAddress &&
                                          _billingAddress &&
                                          !orderProvider.sameAsBilling)) {
                                    RouterHelper
                                        .getSavedBillingAddressListRoute(
                                            fromGuest:
                                                !Provider.of<AuthController>(
                                                        context,
                                                        listen: false)
                                                    .isLoggedIn());
                                    showCustomSnackBarWidget(
                                        getTranslated(
                                            'select_a_billing_address',
                                            context),
                                        Get.context!,
                                        snackBarType: SnackBarType.warning);
                                  } else {
                                    if (!orderProvider.isCheckCreateAccount ||
                                        (orderProvider.isCheckCreateAccount &&
                                            (passwordFormKey.currentState
                                                    ?.validate() ??
                                                false))) {
                                      String orderNote = orderProvider
                                          .orderNoteController.text
                                          .trim();
                                      String couponCode =
                                          couponProvider.discount != null &&
                                                  couponProvider.discount != 0
                                              ? couponProvider.couponCode
                                              : '';
                                      String couponCodeAmount =
                                          couponProvider.discount != null &&
                                                  couponProvider.discount != 0
                                              ? couponProvider.discount
                                                  .toString()
                                              : '0';

                                      String addressId = hasDeliveryAddress
                                          ? addressList[
                                                  orderProvider.addressIndex!]
                                              .id
                                              .toString()
                                          : '';

                                      String billingAddressId =
                                          (_billingAddress)
                                              ? !orderProvider.sameAsBilling
                                                  ? addressList[orderProvider
                                                          .billingAddressIndex!]
                                                      .id
                                                      .toString()
                                                  : addressId
                                              : '';

                                      if (orderProvider.isCODChecked &&
                                          !widget.onlyDigital) {
                                        orderProvider.placeOrder(
                                            callback: _callback,
                                            addressID: addressId,
                                            couponCode: couponCode,
                                            couponAmount: couponCodeAmount,
                                            billingAddressId: billingAddressId,
                                            orderNote: orderNote);
                                      } else if (orderProvider
                                          .isOfflineChecked) {
                                        RouterHelper.getOfflinePaymentScreen(
                                            payableAmount: _payableAmount,
                                            callback: _callback);
                                      } else if (orderProvider
                                          .isWalletChecked) {
                                        showAnimatedDialog(
                                            context,
                                            WalletPaymentWidget(
                                                currentBalance:
                                                    profileProvider.balance ??
                                                        0,
                                                orderAmount: _payableAmount,
                                                onTap: () {
                                                  if (profileProvider.balance! <
                                                      _payableAmount) {
                                                    showCustomSnackBarWidget(
                                                        getTranslated(
                                                            'insufficient_balance',
                                                            context),
                                                        context,
                                                        snackBarType:
                                                            SnackBarType
                                                                .warning);
                                                  } else {
                                                    Navigator.pop(context);
                                                    orderProvider.placeOrder(
                                                        callback: _callback,
                                                        wallet: true,
                                                        addressID: addressId,
                                                        couponCode: couponCode,
                                                        couponAmount:
                                                            couponCodeAmount,
                                                        billingAddressId:
                                                            billingAddressId,
                                                        orderNote: orderNote);
                                                  }
                                                }),
                                            dismissible: false,
                                            willFlip: true);
                                      } else {
                                        showCustomSnackBarWidget(
                                          getTranslated('select_payment_method',
                                                  context) ??
                                              'يرجى تحديد طريقة الدفع أولاً لإتمام الطلب',
                                          context,
                                          snackBarType: SnackBarType.warning,
                                        );
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (c) {
                                            return PaymentMethodBottomSheetWidget(
                                              onlyDigital: widget.onlyDigital,
                                              payableAmount: _payableAmount,
                                            );
                                          },
                                        );
                                      }
                                    }
                                  }
                                },
                          buttonText: deliveryAddressMissing
                              ? 'إضافة عنوان التوصيل'
                              : orderProvider.isOfflineChecked
                                  ? 'متابعة إلى بيانات الدفع'
                                  : 'تأكيد الطلب',
                        ),
                      ],
                    ),
                  ),
                );
              });
            });
          });
        });
      }),
      appBar: const CustomAppBar(
        title: 'إتمام الطلب',
        iconColor: Color(0xFF015FC9),
      ),
      body: Consumer<AuthController>(builder: (context, authProvider, _) {
        return Consumer<CheckoutController>(
            builder: (context, orderProvider, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  children: [
                    SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault),
                      child: ShippingDetailsWidget(
                        hasPhysical: widget.hasPhysical,
                        billingAddress: _billingAddress,
                        passwordFormKey: passwordFormKey,
                        showDistanceEstimate: false,
                      ),
                    ),
                    _buildDeliveryInfoCard(context),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CheckoutProductsSummary(cartItems: widget.cartList),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    if (Provider.of<AuthController>(context, listen: false)
                        .isLoggedIn())
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeSmall),
                        child: CouponApplyWidget(
                          couponController: _controller,
                          orderAmount: _order,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ChoosePaymentWidget(
                        onlyDigital: widget.onlyDigital,
                        payableAmount: _payableAmount,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    // Order Summary Card matching screenshot
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE1E8F2)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AllineColors.primaryDark.withValues(alpha: .03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Consumer<CheckoutController>(
                        builder: (context, checkoutController, child) {
                          _couponDiscount =
                              Provider.of<CouponController>(context).discount ??
                                  0;
                          _referralDiscount =
                              Provider.of<CheckoutController>(context)
                                      .referralAmount
                                      ?.amount ??
                                  0;
                          final deliveryCost = widget.shippingFee;
                          final totalPayable = _order +
                              deliveryCost -
                              (_referralDiscount ?? 0) -
                              widget.discount -
                              (_couponDiscount ?? 0) +
                              _tax;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ملخص الطلب',
                                style: textBold.copyWith(
                                  fontSize: 16,
                                  color: const Color(0xFF071B49),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSummaryRow(
                                title: 'إجمالي المنتجات',
                                value: PriceConverter.convertPrice(
                                    context, _order),
                              ),
                              const SizedBox(height: 8),
                              if (widget.discount > 0) ...[
                                _buildSummaryRow(
                                  title: 'الخصم',
                                  value:
                                      '- ${PriceConverter.convertPrice(context, widget.discount)}',
                                  isDiscount: true,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if ((_couponDiscount ?? 0) > 0) ...[
                                _buildSummaryRow(
                                  title: 'خصم القسيمة',
                                  value:
                                      '- ${PriceConverter.convertPrice(context, _couponDiscount)}',
                                  isDiscount: true,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if ((_referralDiscount ?? 0) > 0) ...[
                                _buildSummaryRow(
                                  title: 'خصم الإحالة',
                                  value:
                                      '- ${PriceConverter.convertPrice(context, _referralDiscount)}',
                                  isDiscount: true,
                                ),
                                const SizedBox(height: 8),
                              ],
                              _buildSummaryRow(
                                title: 'رسوم التوصيل',
                                value: PriceConverter.convertPrice(
                                    context, deliveryCost),
                              ),
                              if (splashController.configModel
                                          ?.systemTaxIncludeStatus !=
                                      1 &&
                                  _tax > 0) ...[
                                const SizedBox(height: 8),
                                _buildSummaryRow(
                                  title: 'الضريبة',
                                  value: PriceConverter.convertPrice(
                                      context, _tax),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF0F4FA)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الإجمالي',
                                    style: textBold.copyWith(
                                      fontSize: 16,
                                      color: const Color(0xFF071B49),
                                    ),
                                  ),
                                  Text(
                                    PriceConverter.convertPrice(
                                        context, totalPayable),
                                    style: textBold.copyWith(
                                      fontSize: 18,
                                      color: const Color(0xFF015FC9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE1E8F2)),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                              '${getTranslated('order_note', context)}',
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextFieldWidget(
                            hintText: getTranslated('enter_note', context),
                            inputType: TextInputType.multiline,
                            inputAction: TextInputAction.done,
                            maxLines: 3,
                            focusNode: _orderNoteNode,
                            controller: orderProvider.orderNoteController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildWhatsAppSupport(context),
                    SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
            ],
          );
        });
      }),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String value,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textRegular.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF6D85AF),
          ),
        ),
        Text(
          value,
          style: isDiscount
              ? textBold.copyWith(
                  fontSize: 13.5,
                  color: const Color(0xFF10B981),
                )
              : textMedium.copyWith(
                  fontSize: 13.5,
                  color: const Color(0xFF071B49),
                ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfoCard(BuildContext context) {
    final feeText = PriceConverter.convertPrice(context, widget.shippingFee);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F2)),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primaryDark.withValues(alpha: .03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF015FC9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التوصيل',
                      style: textBold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF071B49),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'رسوم خيار الشحن المحدد في السلة.',
                      style: textRegular.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F4FA)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الشحن المختار',
                style: textBold.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF071B49),
                ),
              ),
              Text(
                feeText,
                style: textBold.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF015FC9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppSupport(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F2)),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primaryDark.withValues(alpha: .03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تحتاج مساعدة؟',
            style: textBold.copyWith(
              fontSize: 14,
              color: const Color(0xFF071B49),
            ),
          ),
          InkWell(
            onTap: () => _openWhatsApp(context),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF25D366),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'تواصل معنا عبر واتساب',
                  style: textBold.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    const message = 'مرحبًا، أحتاج مساعدة بخصوص طلبي من Alline.';
    final appUri = Uri.parse(
      'whatsapp://send?phone=967775667733&text=${Uri.encodeComponent(message)}',
    );
    final webUri = Uri.parse(
      'https://wa.me/967775667733?text=${Uri.encodeComponent(message)}',
    );

    var opened = false;
    try {
      opened = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      try {
        opened = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && context.mounted) {
      showCustomSnackBarWidget(
        'تعذر فتح واتساب. يرجى المحاولة مرة أخرى.',
        context,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void _callback(bool isSuccess, String message, String orderID,
      bool createAccount) async {
    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouterHelper.getOrderConfirmationRoute(
          orderId: orderID,
          isNewUser: createAccount,
          action: RouteAction.pushReplacement,
        );
      });
    } else {
      showCustomSnackBarWidget(message, context,
          snackBarType: SnackBarType.error);
    }
  }
}

class _CheckoutRequirementMessage extends StatelessWidget {
  final String text;
  final IconData icon;

  const _CheckoutRequirementMessage({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6D85AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: textRegular.copyWith(
              fontSize: 12,
              color: const Color(0xFF6D85AF),
            ),
          ),
        ),
      ],
    );
  }
}
