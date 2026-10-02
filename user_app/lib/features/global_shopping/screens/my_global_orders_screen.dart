import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_logo_widget.dart';
import 'package:provider/provider.dart';

class MyGlobalOrdersScreen extends StatefulWidget {
  const MyGlobalOrdersScreen({super.key});

  @override
  State<MyGlobalOrdersScreen> createState() => _MyGlobalOrdersScreenState();
}

class _MyGlobalOrdersScreenState extends State<MyGlobalOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<GlobalShoppingController>(context, listen: false)
        .getMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Scaffold(
      backgroundColor:
          isDark ? Theme.of(context).cardColor : const Color(0xFFF7F9FA),
      appBar: CustomAppBar(
          title: isLtr ? 'My Global Requests' : 'طلباتي من المواقع العالمية'),
      body: Consumer<GlobalShoppingController>(
        builder: (context, globalCtrl, _) {
          if (globalCtrl.isRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (globalCtrl.requestsList.isEmpty) {
            return Center(
              child: NoInternetOrDataScreenWidget(
                isNoInternet: false,
                message: isLtr
                    ? 'You have no global shopping requests yet'
                    : 'ليس لديك أي طلبات شراء عالمية حتى الآن',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => globalCtrl.getMyRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: globalCtrl.requestsList.length,
              itemBuilder: (context, index) {
                final req = globalCtrl.requestsList[index];
                return _requestCard(context, req, isLtr, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _requestCard(BuildContext context, GlobalShoppingRequestModel req,
      bool isLtr, bool isDark) {
    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    switch (req.status) {
      case 'priced':
      case 'approved':
        statusColor = const Color(0xFF168B4A);
        statusTitle =
            isLtr ? 'Priced - Ready to Order' : 'تم التسعير - جاهز للشراء';
        statusIcon = Icons.check_circle;
        break;
      case 'ordered':
      case 'shipped':
        statusColor = const Color(0xFF2196F3);
        statusTitle = isLtr
            ? 'Purchased & Shipping ✈️'
            : 'تم الشراء وجاري الشحن الدولي ✈️';
        statusIcon = Icons.flight_takeoff;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusTitle = isLtr ? 'Delivered' : 'تم التسليم بنجاح';
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = const Color(0xFFFF9800);
        statusTitle =
            isLtr ? 'Under Pricing & Review ⏳' : 'قيد المراجعة والتسعير ⏳';
        statusIcon = Icons.hourglass_top;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusTitle,
                      style:
                          textBold.copyWith(color: statusColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (req.createdAt != null)
                Text(
                  req.createdAt!.substring(0, 10),
                  style: textRegular.copyWith(
                      color: Theme.of(context).hintColor, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: GlobalStoreLogoWidget(
                  storeName: req.storeName,
                  height: 14,
                  width: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${req.storeName ?? "Global Store"} (الكمية: ${req.quantity})',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            req.productUrl ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeExtraSmall),
          ),
          if (req.customerNotes != null && req.customerNotes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'ملاحظاتك: ${req.customerNotes}',
              style: textRegular.copyWith(
                  fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
          if (req.approvedPrice != null &&
              req.approvedPrice! > 0 &&
              req.approvedProductId != null) ...[
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('السعر المعتمد الواصل:',
                        style: textRegular.copyWith(
                            fontSize: 10, color: Theme.of(context).hintColor)),
                    Text(
                      _formatApprovedPrice(req),
                      style: textBold.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () async {
                    if (req.approvedProductId == null) return;
                    final cartController = context.read<CartController>();
                    if (cartController.addToCartLoading) return;
                    final response =
                        await cartController.addToCartAPISilent(
                      CartModelBody(
                        productId: req.approvedProductId,
                        quantity: req.quantity ?? 1,
                        variant: '',
                        color: '',
                      ),
                      context,
                      [],
                      [],
                    );
                    final success = response.response?.statusCode == 200 ||
                        response.response?.statusCode == 201;

                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      showCustomSnackBarWidget(
                        isLtr
                            ? 'Added to cart successfully'
                            : 'تمت إضافة الطلب إلى السلة بنجاح',
                        context,
                        snackBarType: SnackBarType.success,
                      );
                      RouterHelper.getCartScreenRoute(
                          action: RouteAction.push, showBackButton: true);
                    }
                  },
                  child: Text('إتمام الشراء 🛒',
                      style:
                          textBold.copyWith(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatApprovedPrice(GlobalShoppingRequestModel req) {
    final currency = (req.quotedCurrency ?? 'YER').toUpperCase();
    final price = req.approvedPrice ?? 0;

    if (currency == 'USD') {
      return '\$${price.toStringAsFixed(2)} USD';
    }

    return '${price.toStringAsFixed(0)} $currency';
  }
}
