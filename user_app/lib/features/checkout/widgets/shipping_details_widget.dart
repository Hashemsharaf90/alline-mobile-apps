import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/create_account_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/select_location_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/delivery_distance_helper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class ShippingDetailsWidget extends StatefulWidget {
  final bool hasPhysical;
  final bool billingAddress;
  final GlobalKey<FormState> passwordFormKey;
  final Function(double distanceKm, double deliveryFeeYer)? onDeliveryCalculated;

  const ShippingDetailsWidget(
      {super.key,
      required this.hasPhysical,
      required this.billingAddress,
      required this.passwordFormKey,
      this.onDeliveryCalculated});

  @override
  State<ShippingDetailsWidget> createState() => _ShippingDetailsWidgetState();
}

class _ShippingDetailsWidgetState extends State<ShippingDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    bool isGuestMode =
        !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    return Consumer<CheckoutController>(
        builder: (context, shippingProvider, _) {
      if (shippingProvider.sameAsBilling && !widget.hasPhysical) {
        shippingProvider.setSameAsBilling(isUpdate: false);
      }

      return Consumer<AddressController>(
          builder: (context, locationProvider, _) {
        final addressList = locationProvider.addressList ?? [];
        if (shippingProvider.addressIndex == null && addressList.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && shippingProvider.addressIndex == null) {
              int defaultIndex = addressList.indexWhere((a) => a.isBilling == true);
              if (defaultIndex == -1) defaultIndex = 0;
              shippingProvider.setAddressIndex(defaultIndex);
              if (shippingProvider.sameAsBilling) {
                shippingProvider.setBillingAddressIndex(defaultIndex);
              }
            }
          });
        }
        final deliveryAddress = shippingProvider.addressIndex != null &&
                shippingProvider.addressIndex! >= 0 &&
                shippingProvider.addressIndex! < addressList.length
            ? addressList[shippingProvider.addressIndex!]
            : null;
        final billingAddress = shippingProvider.billingAddressIndex != null &&
                shippingProvider.billingAddressIndex! >= 0 &&
                shippingProvider.billingAddressIndex! < addressList.length
            ? addressList[shippingProvider.billingAddressIndex!]
            : null;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          widget.hasPhysical
              ? Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  Icons.location_on_rounded,
                                  color: Color(0xFF015FC9),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                getTranslated('delivery_address', context) ?? 'عنوان التوصيل',
                                style: textBold.copyWith(
                                  fontSize: 16,
                                  color: const Color(0xFF071B49),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              RouterHelper.getSavedAddressListRoute(
                                  fromGuest: isGuestMode);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text(
                                deliveryAddress != null ? 'تغيير' : 'اختيار',
                                style: textBold.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF015FC9),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (deliveryAddress != null) ...[
                        Text(
                          deliveryAddress.addressType ?? 'المنزل',
                          style: textBold.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF071B49),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF015FC9),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ('${deliveryAddress.city ?? ''} ${deliveryAddress.address ?? ''}').trim().isNotEmpty
                                    ? ('${deliveryAddress.city ?? ''} ${deliveryAddress.address ?? ''}').trim()
                                    : 'صنعاء، حدة',
                                style: textRegular.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF6D85AF),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDistanceDeliveryCard(context, deliveryAddress, locationProvider),
                      ] else ...[
                        InkWell(
                          onTap: () => RouterHelper.getSavedAddressListRoute(fromGuest: isGuestMode),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F8FE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE1E8F2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_location_alt_outlined, color: Color(0xFF015FC9), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'تحديد عنوان التوصيل',
                                  style: textMedium.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF015FC9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox(),
          SizedBox(
              height: widget.hasPhysical ? Dimensions.paddingSizeSmall : 0),
          isGuestMode
              ? (widget.hasPhysical)
                  ? CreateAccountWidget(formKey: widget.passwordFormKey)
                  : const SizedBox()
              : const SizedBox(),
          isGuestMode
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          if (widget.billingAddress || shippingProvider.sameAsBilling)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                      spreadRadius: 3,
                      blurRadius: 3)
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CustomAssetImageWidget(Images.billingTo,
                                      height: 20, width: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeExtraSmall),
                                    child: Text(
                                      '${getTranslated('billing_to', context)}',
                                      style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.hasPhysical && widget.billingAddress)
                              Container(
                                padding: EdgeInsets.all(
                                    Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.07),
                                ),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () =>
                                      shippingProvider.setSameAsBilling(),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall),
                                        SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                              alpha: .75),
                                                      width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  color: shippingProvider
                                                          .sameAsBilling
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .cardColor,
                                                ),
                                                child: Icon(
                                                    CupertinoIcons
                                                        .checkmark_alt,
                                                    size: 15,
                                                    color: shippingProvider
                                                            .sameAsBilling
                                                        ? Theme.of(context)
                                                            .cardColor
                                                        : Colors.transparent))),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Text(
                                                getTranslated(
                                                    'same_as_delivery',
                                                    context)!,
                                                style: textRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color)))
                                      ]),
                                ),
                              ),
                            if (!shippingProvider.sameAsBilling)
                              SizedBox(width: Dimensions.paddingSizeSmall),
                            if (!shippingProvider.sameAsBilling)
                              InkWell(
                                onTap: () => RouterHelper
                                    .getSavedBillingAddressListRoute(
                                        fromGuest: isGuestMode),
                                child: SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                      Images.edit,
                                      scale: 3,
                                      color: Theme.of(context).primaryColor,
                                    )),
                              ),
                          ]),
                    ),
                    if (!shippingProvider.sameAsBilling) ...[
                      SizedBox(
                          height: 1, child: const Divider(thickness: .200)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],
                    if (!shippingProvider.sameAsBilling)
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            billingAddress != null
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault),
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${getTranslated('name', context)} : ',
                                                style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color),
                                              ),
                                              Text(
                                                billingAddress
                                                        .contactPersonName ??
                                                    '',
                                                style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${getTranslated('phone', context)} : ',
                                                style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color),
                                              ),
                                              Text(
                                                billingAddress.phone ?? '',
                                                style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      Container(
                                        padding: EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withValues(alpha: 0.07)),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall),
                                            CustomAssetImageWidget(
                                                Images.savedAddressLocationIcon,
                                                height: 20,
                                                width: 20),
                                            SizedBox(
                                                width: Dimensions
                                                    .paddingSizeSmall),
                                            Text(
                                              '${billingAddress.addressType ?? ''}: ',
                                              style: textMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${billingAddress.address ?? ''}: ',
                                                style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                    ]),
                                  )
                                : SizedBox(
                                    height: 80,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(children: []),
                                        Icon(Icons.two_wheeler_rounded,
                                            color: Theme.of(context).hintColor,
                                            size: 32),
                                        SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Text(
                                          '${getTranslated('please_set_your_billing_info', context)}',
                                          style: textMedium.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                          ]),
                  ]),
            ),
          isGuestMode
              ? (!widget.hasPhysical)
                  ? CreateAccountWidget(formKey: widget.passwordFormKey)
                  : const SizedBox()
              : const SizedBox(),
        ]);
      });
    });
  }

  void _openManualAddressSheet(
    BuildContext context,
    AddressModel address,
    AddressController addressController,
  ) {
    final TextEditingController textCtrl =
        TextEditingController(text: address.address ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AllineColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AllineColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'تعديل وصف العنوان يدوياً',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF071B49),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'اكتب وصفاً دقيقاً لعنوان التوصيل (الشارع، المعلم القريب، رقم المبنى أو الشقة):',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  color: Color(0xFF6D85AF),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'مثال: شارع حدة، بجوار مركز الكميم، عمارة 4، الدور الثاني',
                  hintStyle: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    color: Color(0xFF9EADC6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F8FE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E8F2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E8F2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AllineColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final newText = textCtrl.text.trim();
                    if (newText.isNotEmpty) {
                      address.address = newText;
                      await addressController.updateAddress(
                        context,
                        addressModel: address,
                        addressId: address.id,
                      );
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        setState(() {});
                      }
                    }
                  },
                  child: const Text(
                    'تأكيد وحفظ العنوان',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocationFromMap(
    BuildContext context,
    AddressModel address,
    AddressController addressController,
  ) async {
    final locationController =
        Provider.of<LocationController>(context, listen: false);
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const SelectLocationScreen(googleMapController: null),
      ),
    );

    if (!context.mounted) return;
    if (result == true &&
        locationController.pickPosition.latitude != 0 &&
        locationController.pickPosition.longitude != 0) {
      address.latitude = locationController.pickPosition.latitude.toString();
      address.longitude = locationController.pickPosition.longitude.toString();
      if (locationController.locationController.text.trim().isNotEmpty) {
        address.address = locationController.locationController.text.trim();
      }
      await addressController.updateAddress(
        context,
        addressModel: address,
        addressId: address.id,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildDistanceDeliveryCard(
    BuildContext context,
    AddressModel deliveryAddress,
    AddressController addressController,
  ) {
    final double? destLat =
        DeliveryDistanceHelper.parseCoordinate(deliveryAddress.latitude);
    final double? destLng =
        DeliveryDistanceHelper.parseCoordinate(deliveryAddress.longitude);
    final bool hasCoords =
        destLat != null && destLng != null && destLat != 0.0 && destLng != 0.0;

    final double distanceKm = hasCoords
        ? DeliveryDistanceHelper.calculateRoadDistanceKm(
            destinationLat: destLat,
            destinationLng: destLng,
          )
        : 0.0;

    final double feeYer = hasCoords
        ? DeliveryDistanceHelper.calculateFeeFromDistanceKm(distanceKm)
        : DeliveryDistanceHelper.minFeeYer;

    final int etaMinutes = DeliveryDistanceHelper.calculateEtaMinutes(distanceKm);
    final String etaText = DeliveryDistanceHelper.formatEtaText(etaMinutes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDeliveryCalculated?.call(distanceKm, feeYer);
    });

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4E3F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AllineColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: AllineColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التوصيل السريع — متجر Alline',
                      style: textBold.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF071B49),
                      ),
                    ),
                    Text(
                      'نقطة الانطلاق: شارع الزراعة، صنعاء',
                      style: textRegular.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AllineColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${feeYer.toInt()} ر.ي',
                  style: textBold.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE1E8F2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.straighten_rounded,
                      size: 15,
                      color: Color(0xFF6D85AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'المسافة عبر الطريق: ',
                      style: textRegular.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                    Text(
                      hasCoords
                          ? '$distanceKm كم'
                          : 'صنعاء (يُحدد حسب الخريطة)',
                      style: textBold.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF071B49),
                      ),
                    ),
                  ],
                ),
                Text(
                  '(250 ر.ي / كم)',
                  style: textRegular.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF6D85AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE1E8F2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Color(0xFF6D85AF),
                ),
                const SizedBox(width: 4),
                Text(
                  'الوقت المقدر للوصول: ',
                  style: textRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF6D85AF),
                  ),
                ),
                Text(
                  hasCoords ? etaText : '30 - 45 دقيقة',
                  style: textBold.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF071B49),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickLocationFromMap(
                      context, deliveryAddress, addressController),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AllineColors.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          size: 14,
                          color: AllineColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'تحديد عبر GPS',
                          style: textBold.copyWith(
                            fontSize: 11,
                            color: AllineColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _openManualAddressSheet(
                      context, deliveryAddress, addressController),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE1E8F2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 16,
                          color: Color(0xFF071B49),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'كتابة وصف يدوي',
                          style: textBold.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF071B49),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddressInfoItem extends StatelessWidget {
  final String? icon;
  final String? title;
  const AddressInfoItem({super.key, this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(children: [
        SizedBox(width: 18, child: Image.asset(icon!)),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                child: Text(title ?? '',
                    style: textRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    maxLines: 2,
                    overflow: TextOverflow.fade)))
      ]),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
