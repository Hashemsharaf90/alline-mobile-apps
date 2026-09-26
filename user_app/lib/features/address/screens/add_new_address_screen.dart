import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart'
    as config;
import 'package:flutter_sixvalley_ecommerce/helper/country_code_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/success_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final bool? isBilling;
  const AddNewAddressScreen(
      {super.key,
      this.isEnableUpdate = false,
      this.address,
      this.fromCheckout = false,
      this.isBilling});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonEmailController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  Address? _address;
  String zip = '', country = 'YE';
  late LatLng _defaut;
  GoogleMapController? _mapController;

  final GlobalKey<FormState> _addressFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    config.DefaultLocation? dLocation =
        Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.defaultLocation;
    _defaut = LatLng(
      double.tryParse(dLocation?.lat ?? '') ?? 15.3694,
      double.tryParse(dLocation?.lng ?? '') ?? 44.1910,
    );

    if (widget.isBilling == true) {
      _address = Address.billing;
    } else {
      _address = Address.shipping;
    }

    final String initialCountryCode = _resolveInitialCountryCode();
    final CountryCode initialCountry =
        CountryCode.fromCountryCode(initialCountryCode);
    Provider.of<AuthController>(context, listen: false)
        .setCountryCode(initialCountry.dialCode ?? '+967', notify: false);
    _countryCodeController.text = initialCountry.name ?? 'Yemen';
    Provider.of<AddressController>(context, listen: false).getAddressType();
    Provider.of<AddressController>(context, listen: false)
        .getRestrictedDeliveryCountryList();
    Provider.of<AddressController>(context, listen: false)
        .getRestrictedDeliveryZipList();

    _checkPermission(
        () => Provider.of<LocationController>(context, listen: false)
            .getCurrentLocation(context, true),
        context);
    if (widget.isEnableUpdate && widget.address != null) {
      Provider.of<LocationController>(context, listen: false)
          .setPickedCoordinates(
        latitude: _parseCoordinate(widget.address?.latitude, _defaut.latitude),
        longitude:
            _parseCoordinate(widget.address?.longitude, _defaut.longitude),
        fromAddress: true,
        address: widget.address!.address,
        context: context,
      );
      _contactPersonNameController.text =
          '${widget.address?.contactPersonName}';
      _countryCodeController.text = '${widget.address?.country}';
      _contactPersonEmailController.text = '${widget.address?.email}';
      // _contactPersonNumberController.text = '${widget.address?.phone}';
      _cityController.text = (widget.address?.city != null && widget.address!.city!.isNotEmpty) ? widget.address!.city! : 'صنعاء';
      _zipCodeController.text = (widget.address?.zip != null && widget.address!.zip!.isNotEmpty) ? widget.address!.zip! : '00000';
      if (widget.address!.addressType == 'Home') {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(0, false);
      } else if (widget.address!.addressType == 'Workplace') {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(1, false);
      } else {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(2, false);
      }
      String countryCode =
          CountryCodeHelper.getCountryCode(widget.address?.phone ?? '') ??
              '+967';
      Provider.of<AuthController>(context, listen: false)
          .setCountryCode(countryCode, notify: false);
      String phoneNumberOnly = CountryCodeHelper.extractPhoneNumber(
          countryCode, widget.address?.phone ?? '');
      _contactPersonNumberController.text = phoneNumberOnly;
    } else {
      _cityController.text = 'صنعاء';
      _zipCodeController.text = '00000';
      _countryCodeController.text = 'Yemen';
      if (Provider.of<ProfileController>(context, listen: false)
              .userInfoModel !=
          null) {
        _contactPersonNameController.text =
            '${Provider.of<ProfileController>(context, listen: false).userInfoModel!.fName ?? ''}'
            ' ${Provider.of<ProfileController>(context, listen: false).userInfoModel!.lName ?? ''}';

        final String profilePhone =
            Provider.of<ProfileController>(context, listen: false)
                    .userInfoModel!
                    .phone ??
                '';
        String countryCode =
            CountryCodeHelper.getCountryCode(profilePhone) ?? '+967';
        Provider.of<AuthController>(context, listen: false)
            .setCountryCode(countryCode);
        _contactPersonNumberController.text =
            CountryCodeHelper.extractPhoneNumber(countryCode, profilePhone);
      }
    }
  }

  String _resolveInitialCountryCode() {
    final String? configuredCountry =
        Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.countryCode;
    if (configuredCountry != null && configuredCountry.trim().isNotEmpty) {
      return configuredCountry.trim();
    }
    return 'YE';
  }

  double _parseCoordinate(String? value, double fallback) {
    if (value == null || value.trim().isEmpty || value == '0') {
      return fallback;
    }

    return double.tryParse(value) ?? fallback;
  }

  LatLng _addressMapCenter(LocationController locationController) {
    if (widget.isEnableUpdate) {
      return LatLng(
        _parseCoordinate(widget.address?.latitude, _defaut.latitude),
        _parseCoordinate(widget.address?.longitude, _defaut.longitude),
      );
    }

    final latitude = locationController.position.latitude;
    final longitude = locationController.position.longitude;

    if (latitude == 0 || longitude == 0) {
      return _defaut;
    }

    return LatLng(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.isEnableUpdate
              ? getTranslated('update_address', context)
              : getTranslated('add_new_address', context),
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
            }
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<AddressController>(
              builder: (context, addressController, child) {
                if (Provider.of<SplashController>(context, listen: false)
                            .configModel!
                            .deliveryCountryRestriction ==
                        1 &&
                    addressController.restrictedCountryList.isNotEmpty) {
                  _countryCodeController.text =
                      addressController.restrictedCountryList[0];
                }
                return Consumer<LocationController>(
                    builder: (context, locationController, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Form(
                      key: _addressFormKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeLarge),
                                child: CustomTextFieldWidget(
                                  required: true,
                                  prefixIcon: Images.user,
                                  labelText: getTranslated(
                                      'enter_contact_person_name', context),
                                  hintText: getTranslated(
                                      'enter_contact_person_name', context),
                                  inputType: TextInputType.name,
                                  controller: _contactPersonNameController,
                                  focusNode: _nameNode,
                                  nextFocus: _numberNode,
                                  inputAction: TextInputAction.next,
                                  capitalization: TextCapitalization.words,
                                  validator: (value) =>
                                      ValidateCheck.validateEmptyText(value,
                                          'contact_person_name_is_required'),
                                )),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            Consumer<AuthController>(
                                builder: (context, authProvider, _) {
                              return CustomTextFieldWidget(
                                required: true,
                                labelText: getTranslated('phone', context),
                                hintText: getTranslated(
                                    'enter_mobile_number', context),
                                controller: _contactPersonNumberController,
                                focusNode: _numberNode,
                                nextFocus: _emailNode,
                                showCodePicker: true,
                                countryDialCode: authProvider.countryDialCode,
                                onCountryChanged: (CountryCode countryCode) {
                                  authProvider.countryDialCode =
                                      countryCode.dialCode!;
                                  authProvider
                                      .setCountryCode(countryCode.dialCode!);
                                },
                                isAmount: true,
                                validator: (value) =>
                                    ValidateCheck.validateEmptyText(
                                        value, "phone_must_be_required"),
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.phone,
                              );
                            }),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            if (!Provider.of<AuthController>(context,
                                    listen: false)
                                .isLoggedIn())
                              CustomTextFieldWidget(
                                required: true,
                                prefixIcon: Images.email,
                                labelText: getTranslated('email', context),
                                hintText: getTranslated(
                                    'enter_contact_person_email', context),
                                inputType: TextInputType.emailAddress,
                                controller: _contactPersonEmailController,
                                focusNode: _emailNode,
                                nextFocus: _addressNode,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                validator: (value) =>
                                    ValidateCheck.validateEmail(value),
                              ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            SizedBox(
                                height: MediaQuery.of(context).size.width / 2,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.paddingSizeSmall),
                                    child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          GoogleMap(
                                            key: ValueKey(
                                                '${locationController.position.latitude}_${locationController.position.longitude}'),
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: _addressMapCenter(
                                                  locationController),
                                              zoom: 16,
                                            ),
                                            mapType: MapType.normal,
                                            compassEnabled: false,
                                            myLocationButtonEnabled: false,
                                            zoomControlsEnabled: false,
                                            mapToolbarEnabled: false,
                                            onMapCreated: (controller) =>
                                                _mapController = controller,
                                            onTap: (_) => RouterHelper
                                                .getSelectLocationScreen(
                                              googleMapController:
                                                  _mapController,
                                              action: RouteAction.push,
                                            ),
                                          ),
                                          if (locationController.loading)
                                            Center(
                                                child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Theme.of(
                                                                context)
                                                            .primaryColor))),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              alignment: Alignment.center,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: Icon(
                                                Icons.location_on,
                                                size: 40,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )),
                                          Positioned(
                                              top: 10,
                                              right: 0,
                                              child: InkWell(
                                                  onTap: () => RouterHelper
                                                          .getSelectLocationScreen(
                                                        googleMapController:
                                                            _mapController,
                                                        action:
                                                            RouteAction.push,
                                                      ),
                                                  child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      margin: const EdgeInsets
                                                          .only(
                                                          right: Dimensions
                                                              .paddingSizeLarge),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .paddingSizeSmall),
                                                        color: Colors.white,
                                                      ),
                                                      child: Icon(
                                                          Icons.fullscreen,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: 20))))
                                        ]))),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall),
                              child: Text(getTranslated('label_us', context)!,
                                  style: textRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeLarge,
                                  )),
                            ),
                            SizedBox(
                                height: 50,
                                child: RepaintBoundary(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: addressController
                                          .addressTypeList.length,
                                      itemBuilder: (context, index) => InkWell(
                                          onTap: () => addressController
                                              .updateAddressIndex(index, true),
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: Dimensions
                                                      .paddingSizeDefault,
                                                  horizontal: Dimensions
                                                      .paddingSizeLarge),
                                              margin: const EdgeInsets.only(
                                                  right: 17),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                      Dimensions
                                                          .paddingSizeSmall),
                                                  border: Border.all(
                                                      color: addressController.selectAddressIndex == index
                                                          ? Theme.of(context).primaryColor
                                                          : Theme.of(context).primaryColor.withValues(alpha: .125))),
                                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                SizedBox(
                                                    width: 20,
                                                    child: Image.asset(
                                                        addressController
                                                            .addressTypeList[
                                                                index]
                                                            .icon,
                                                        color:
                                                            addressController
                                                                        .selectAddressIndex ==
                                                                    index
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                : Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withValues(
                                                                        alpha:
                                                                            .35))),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                Text(
                                                    getTranslated(
                                                        addressController
                                                            .addressTypeList[
                                                                index]
                                                            .title,
                                                        context)!,
                                                    style:
                                                        textRegular.copyWith())
                                              ])))),
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeSmall),
                              child: SizedBox(
                                height: 50,
                                child: RadioGroup<Address>(
                                  groupValue: _address,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _address = value;
                                      });
                                    }
                                  },
                                  child: Row(children: [
                                    Row(children: [
                                      Radio<Address>(value: Address.shipping),
                                      Text(
                                          getTranslated('shipping_address',
                                                  context) ??
                                              '',
                                          style: textRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          )),
                                    ]),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Row(children: [
                                      Radio<Address>(value: Address.billing),
                                      Text(
                                          getTranslated(
                                                  'billing_address', context) ??
                                              '',
                                          style: textRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          )),
                                    ]),
                                  ]),
                                ),
                              ),
                            ),
                            CustomTextFieldWidget(
                              labelText:
                                  getTranslated('delivery_address', context),
                              hintText: 'وصف تفصيلي للعنوان (الشارع، المعلم، المبنى)',
                              inputType: TextInputType.streetAddress,
                              inputAction: TextInputAction.done,
                              focusNode: _addressNode,
                              prefixIcon: Images.address,
                              required: true,
                              controller: locationController.locationController,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, "address_is_required"),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefaultAddress),
                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: CustomButton(
                                isLoading: addressController.isLoading,
                                buttonText: widget.isEnableUpdate
                                    ? getTranslated('update_address', context)
                                    : getTranslated('save_location', context),
                                onTap: locationController.loading
                                    ? null
                                    : () {
                                        if (_addressFormKey.currentState
                                                ?.validate() ??
                                            false) {
                                          AddressModel addressModel =
                                              AddressModel(
                                            addressType: addressController
                                                .addressTypeList[
                                                    addressController
                                                        .selectAddressIndex]
                                                .title,
                                            contactPersonName:
                                                _contactPersonNameController
                                                    .text,
                                            phone:
                                                '${Provider.of<AuthController>(context, listen: false).countryDialCode}${_contactPersonNumberController.text.trim()}',
                                            email: _contactPersonEmailController
                                                .text
                                                .trim(),
                                            city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'صنعاء',
                                            zip: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : '00000',
                                            country: _countryCodeController.text.trim().isNotEmpty ? _countryCodeController.text.trim() : 'Yemen',
                                            guestId:
                                                Provider.of<AuthController>(
                                                        context,
                                                        listen: false)
                                                    .getGuestToken(),
                                            isBilling:
                                                _address == Address.billing,
                                            address: locationController
                                                .locationController.text,
                                            latitude: widget.isEnableUpdate
                                                ? locationController
                                                    .position.latitude
                                                    .toString()
                                                : locationController
                                                    .position.latitude
                                                    .toString(),
                                            longitude: widget.isEnableUpdate
                                                ? locationController
                                                    .position.longitude
                                                    .toString()
                                                : locationController
                                                    .position.longitude
                                                    .toString(),
                                          );

                                          if (widget.isEnableUpdate) {
                                            addressModel.id =
                                                widget.address!.id;
                                            addressController.updateAddress(
                                                context,
                                                addressModel: addressModel,
                                                addressId: addressModel.id);
                                          } else {
                                            addressController
                                                .addAddress(addressModel)
                                                .then((value) {
                                              if (value.response?.statusCode ==
                                                  200) {
                                                if (widget.fromCheckout) {
                                                  if (context.mounted) {
                                                    final addressList = Provider
                                                            .of<AddressController>(
                                                                context,
                                                                listen: false)
                                                        .addressList;
                                                    final int selectedIndex =
                                                        addressList == null ||
                                                                addressList
                                                                    .isEmpty
                                                            ? 0
                                                            : addressList
                                                                    .length -
                                                                1;
                                                    if (_address ==
                                                        Address.billing) {
                                                      Provider.of<CheckoutController>(
                                                              context,
                                                              listen: false)
                                                          .setBillingAddressIndex(
                                                              selectedIndex);
                                                    } else {
                                                      Provider.of<CheckoutController>(
                                                              context,
                                                              listen: false)
                                                          .setAddressIndex(
                                                              selectedIndex);
                                                    }
                                                    Navigator.pop(context);
                                                    if (Navigator.canPop(
                                                        Get.context!)) {
                                                      Navigator.pop(
                                                          Get.context!);
                                                    }
                                                  }
                                                } else if (context.mounted) {
                                                  if (Navigator.canPop(context)) {
                                                    Navigator.pop(context);
                                                  } else {
                                                    RouterHelper.getDashboardRoute(
                                                        action: RouteAction.pushReplacement);
                                                  }
                                                }
                                              }
                                            });
                                          }
                                        }
                                      },
                              ),
                            ),
                          ]),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      InkWell(
          onTap: () async {
            Navigator.pop(context);
            await Geolocator.requestPermission();
            _checkPermission(callback, Get.context!);
          },
          child: AlertDialog(
              content: SuccessDialog(
                  icon: Icons.location_on_outlined,
                  title: '',
                  description: getTranslated('you_denied', Get.context!))));
    } else if (permission == LocationPermission.deniedForever) {
      InkWell(
          onTap: () async {
            if (context.mounted) {}
            Navigator.pop(context);
            await Geolocator.openAppSettings();
            _checkPermission(callback, Get.context!);
          },
          child: AlertDialog(
              content: SuccessDialog(
                  icon: Icons.location_on_outlined,
                  title: '',
                  description: getTranslated('you_denied', Get.context!))));
    } else {
      callback();
    }
  }
}

enum Address { shipping, billing }
