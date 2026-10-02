import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/controllers/order_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/domain/models/order_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final bool isNewUser;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    this.isNewUser = false,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  // Brand color palette
  static const Color primaryBlue = AllineColors.primary;
  static const Color darkBlue = AllineColors.primaryDark;
  static const Color primaryText = Color(0xFF071B49);
  static const Color secondaryText = Color(0xFF6D85AF);
  static const Color screenBg = Color(0xFFF4F8FE);
  static const Color cardBorder = Color(0xFFE1E8F2);
  static const Color successGreen = AllineColors.success;
  static const Color successBg = Color(0xFFE8F8EE);

  List<String> _orderIds = [];
  String _selectedOrderId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _parseOrderIds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartController>(context, listen: false)
          .getCartData(context, reload: true);
      if (_selectedOrderId.isNotEmpty) {
        _fetchOrderData(_selectedOrderId);
      }
    });
  }

  void _parseOrderIds() {
    _orderIds = widget.orderId
        .split(',')
        .map((e) => e.replaceAll(RegExp(r'[\[\]\s]'), ''))
        .where((e) => e.isNotEmpty)
        .toList();
    if (_orderIds.isNotEmpty) {
      _selectedOrderId = _orderIds.first;
    }
  }

  Future<void> _fetchOrderData(String id) async {
    setState(() => _isLoading = true);
    final orderDetailsController =
        Provider.of<OrderDetailsController>(context, listen: false);
    try {
      await Future.wait([
        orderDetailsController.getOrderFromOrderId(id),
        orderDetailsController.getOrderDetails(id),
      ]);
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _copyOrderId(String id) {
    final formattedId = '#ALN-$id';
    Clipboard.setData(ClipboardData(text: formattedId));
    showCustomSnackBarWidget(
      'تم نسخ رقم الطلب $formattedId',
      context,
      snackBarType: SnackBarType.success,
    );
  }

  Future<void> _openWhatsApp(String? id) async {
    final orderText =
        (id != null && id.isNotEmpty) ? ' رقم الطلب: #ALN-$id' : '';
    final message = 'مرحبًا، لدي استفسار بخصوص طلبي من Alline.$orderText';
    final appUri = Uri.parse(
      'whatsapp://send?phone=967775667733&text=${Uri.encodeComponent(message)}',
    );
    final webUri = Uri.parse(
      'https://wa.me/967775667733?text=${Uri.encodeComponent(message)}',
    );

    var opened = false;
    try {
      opened = await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      try {
        opened = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && mounted) {
      showCustomSnackBarWidget(
        'تعذر فتح واتساب. يرجى المحاولة مرة أخرى.',
        context,
        snackBarType: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: screenBg,
        appBar: _buildAppBar(context),
        body: Consumer<OrderDetailsController>(
          builder: (context, controller, _) {
            final order = controller.orders;
            final items = controller.orderDetails ?? [];

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSuccessHero(),
                  const SizedBox(height: 16),
                  if (_orderIds.length > 1) ...[
                    _buildMultiStoreNotice(),
                    const SizedBox(height: 12),
                    _buildMultiStoreTabs(),
                    const SizedBox(height: 16),
                  ],
                  _buildOrderIdCard(order),
                  const SizedBox(height: 14),
                  _buildStatusTimeline(order),
                  const SizedBox(height: 14),
                  if (_isLoading)
                    _buildShimmerCard()
                  else ...[
                    _buildOrderSummaryCard(order, items),
                    const SizedBox(height: 14),
                    _buildPaymentMethodCard(order),
                    const SizedBox(height: 14),
                    _buildDeliveryAddressCard(order),
                    const SizedBox(height: 14),
                    _buildDeliveryInfoCard(order),
                    const SizedBox(height: 14),
                    if (items.isNotEmpty) ...[
                      _buildProductsPreview(items),
                      const SizedBox(height: 14),
                    ],
                  ],
                  _buildWhatsAppCard(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            RouterHelper.getDashboardRoute(
              action: RouteAction.pushReplacement,
              page: 'home',
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: screenBg,
              border: Border.all(color: cardBorder),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: primaryText,
            ),
          ),
        ),
      ),
      title: Text(
        'تم تأكيد الطلب',
        style: textBold.copyWith(
          fontSize: 17,
          color: primaryText,
          fontFamily: 'AllineTajawal',
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cardBorder, height: 1),
      ),
    );
  }

  Widget _buildSuccessHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: successBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: successGreen.withValues(alpha: 0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: successGreen.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                color: successGreen,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isNewUser
                ? 'تم إنشاء الحساب وتأكيد طلبك بنجاح'
                : 'تم تأكيد طلبك بنجاح',
            textAlign: TextAlign.center,
            style: textBold.copyWith(
              fontSize: 22,
              color: primaryText,
              fontFamily: 'AllineTajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'شكرًا لك، تم استلام طلبك وسيتم البدء في تجهيزه وتوصيله إليك.',
            textAlign: TextAlign.center,
            style: textRegular.copyWith(
              fontSize: 14,
              color: secondaryText,
              height: 1.5,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiStoreNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'تم تقسيم طلبك إلى ${_orderIds.length} طلبات نظرًا لتعدد المتاجر.',
              style: textMedium.copyWith(
                fontSize: 13,
                color: const Color(0xFF92400E),
                fontFamily: 'AllineTajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiStoreTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _orderIds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final id = _orderIds[index];
          final isSelected = id == _selectedOrderId;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (!isSelected) {
                setState(() => _selectedOrderId = id);
                _fetchOrderData(id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryBlue : cardBorder,
                ),
              ),
              child: Center(
                child: Text(
                  'طلب #${index + 1} ($id)',
                  style: textBold.copyWith(
                    fontSize: 13,
                    color: isSelected ? Colors.white : primaryText,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderIdCard(Orders? order) {
    final displayId = _selectedOrderId.isNotEmpty
        ? _selectedOrderId
        : (order?.id?.toString() ?? '');
    final statusText = _mapOrderStatusToArabic(order?.orderStatus);
    final orderDate = order?.createdAt == null
        ? '—'
        : DateConverter.localDateToIsoStringAMPMOrder(
            DateTime.parse(order!.createdAt!),
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoColumn(
              label: 'رقم الطلب',
              value: '#ALN-$displayId',
              valueColor: primaryBlue,
              trailing: InkWell(
                onTap: () => _copyOrderId(displayId),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.copy_rounded, size: 17, color: primaryBlue),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 58, color: cardBorder),
          Expanded(
            child: _InfoColumn(
              label: 'تاريخ الطلب',
              value: orderDate,
              valueColor: primaryText,
              status: statusText,
              statusColor: _getOrderStatusTextColor(order?.orderStatus),
              statusBackground: _getOrderStatusBgColor(order?.orderStatus),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InfoColumn({
    required String label,
    required String value,
    required Color valueColor,
    Widget? trailing,
    String? status,
    Color? statusColor,
    Color? statusBackground,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: textMedium.copyWith(
                  fontSize: 12,
                  color: secondaryText,
                  fontFamily: 'AllineTajawal')),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textBold.copyWith(
                        fontSize: 15,
                        color: valueColor,
                        fontFamily: 'AllineTajawal')),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (status != null) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(status,
                  style: textBold.copyWith(
                      fontSize: 10,
                      color: statusColor,
                      fontFamily: 'AllineTajawal')),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Orders? order) {
    final status = order?.orderStatus?.toLowerCase() ?? 'pending';
    int currentStep = 0;
    if (status == 'confirmed' || status == 'processing') {
      currentStep = 1;
    } else if (status == 'out_for_delivery') {
      currentStep = 2;
    } else if (status == 'delivered') {
      currentStep = 3;
    }

    final steps = [
      'تم الاستلام',
      'جاري التجهيز',
      'قيد التوصيل',
      'تم التسليم',
    ];
    final stepIcons = [
      Icons.check_circle_outline_rounded,
      Icons.inventory_2_outlined,
      Icons.local_shipping_outlined,
      Icons.done_all_rounded,
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (_selectedOrderId.isNotEmpty) {
          RouterHelper.getTrackingResultRoute(orderID: _selectedOrderId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مراحل الطلب',
                  style: textBold.copyWith(
                    fontSize: 14,
                    color: primaryText,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التفاصيل',
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: primaryBlue,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 11,
                      color: primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final stepIndex = index ~/ 2;
                  final isPassed = stepIndex < currentStep;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isPassed ? primaryBlue : cardBorder,
                    ),
                  );
                }
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex <= currentStep;
                final isCurrent = stepIndex == currentStep;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? primaryBlue : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? primaryBlue : cardBorder,
                          width: 2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: primaryBlue.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        stepIcons[stepIndex],
                        size: 14,
                        color: isCompleted ? Colors.white : secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[stepIndex],
                      style: textMedium.copyWith(
                        fontSize: 11,
                        color: isCompleted ? primaryText : secondaryText,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(Orders? order, List<OrderDetailsModel> items) {
    final subtotal = _calculateSubtotal(order, items);
    final discount = (order?.discountAmount ?? 0) + (order?.extraDiscount ?? 0);
    final shipping = order?.shippingCost ?? 0;
    final tax = order?.totalTaxAmount ?? 0;
    final total = order?.orderAmount ?? 0;
    final count = order?.orderDetailsCount ?? items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ملخص الطلب',
                style: textBold.copyWith(
                  fontSize: 15,
                  color: primaryText,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
              'عدد المنتجات', '$count ${count == 1 ? 'منتج' : 'منتجات'}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'إجمالي المنتجات',
            PriceConverter.convertPrice(context, subtotal),
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'الخصم',
              '- ${PriceConverter.convertPrice(context, discount)}',
              valueColor: successGreen,
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow(
            'رسوم التوصيل',
            shipping == 0
                ? 'مجاني'
                : PriceConverter.convertPrice(context, shipping),
            valueColor: shipping == 0 ? successGreen : primaryText,
          ),
          if (tax > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'الضريبة',
              PriceConverter.convertPrice(context, tax),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: cardBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي النهائي',
                style: textBold.copyWith(
                  fontSize: 15,
                  color: primaryText,
                  fontFamily: 'AllineTajawal',
                ),
              ),
              Text(
                PriceConverter.convertPrice(context, total),
                style: textBold.copyWith(
                  fontSize: 20,
                  color: primaryBlue,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textRegular.copyWith(
            fontSize: 13,
            color: secondaryText,
            fontFamily: 'AllineTajawal',
          ),
        ),
        Text(
          value,
          style: textMedium.copyWith(
            fontSize: 13,
            color: valueColor ?? primaryText,
            fontFamily: 'AllineTajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Orders? order) {
    final methodKey = order?.paymentMethod ?? '';
    final methodName = _formatPaymentMethodName(methodKey);
    final walletLogo = Images.getWalletLogo(methodKey);
    final isCOD = methodKey.toLowerCase().contains('cash') ||
        methodKey.toLowerCase().contains('cod');
    final isWallet = methodKey.toLowerCase() == 'wallet';
    final isPaid = order?.paymentStatus == 'paid';

    String paymentStatusLabel;
    Color paymentStatusColor;
    if (isCOD) {
      paymentStatusLabel = 'الدفع عند الاستلام';
      paymentStatusColor = const Color(0xFFD97706);
    } else if (isWallet) {
      paymentStatusLabel = 'تم الخصم من المحفظة';
      paymentStatusColor = successGreen;
    } else if (isPaid) {
      paymentStatusLabel = 'تم الدفع بنجاح';
      paymentStatusColor = successGreen;
    } else {
      paymentStatusLabel = 'بانتظار التأكيد';
      paymentStatusColor = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                color: primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'طريقة الدفع',
                style: textBold.copyWith(
                  fontSize: 15,
                  color: primaryText,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: screenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: walletLogo != null
                    ? Image.asset(walletLogo, fit: BoxFit.contain)
                    : Icon(
                        isCOD
                            ? Icons.two_wheeler_rounded
                            : isWallet
                                ? Icons.account_balance_wallet_outlined
                                : Icons.credit_card_rounded,
                        color: primaryBlue,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodName,
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: primaryText,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paymentStatusLabel,
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: paymentStatusColor,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(Orders? order) {
    final shipping = order?.shippingAddressData;
    final billing = order?.billingAddressData;
    final contactPerson = (shipping?.contactPersonName != null &&
            shipping!.contactPersonName!.isNotEmpty)
        ? shipping.contactPersonName!
        : (billing?.contactPersonName ?? '');
    final phone = (shipping?.phone != null && shipping!.phone!.isNotEmpty)
        ? shipping.phone!
        : (billing?.phone ?? '');
    final city = (shipping?.city != null && shipping!.city!.isNotEmpty)
        ? shipping.city!
        : (billing?.city ?? '');
    final addressLine =
        (shipping?.address != null && shipping!.address!.isNotEmpty)
            ? shipping.address!
            : (billing?.address ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'عنوان التوصيل',
                style: textBold.copyWith(
                  fontSize: 15,
                  color: primaryText,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (contactPerson.isNotEmpty || phone.isNotEmpty) ...[
            Row(
              children: [
                if (contactPerson.isNotEmpty)
                  Text(
                    contactPerson,
                    style: textBold.copyWith(
                      fontSize: 13,
                      color: primaryText,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                if (contactPerson.isNotEmpty && phone.isNotEmpty)
                  Text(' • ', style: textMedium.copyWith(color: secondaryText)),
                if (phone.isNotEmpty)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      phone,
                      style: textMedium.copyWith(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Text(
            [city, addressLine].where((s) => s.isNotEmpty).join('، '),
            style: textRegular.copyWith(
              fontSize: 13,
              color: primaryText,
              height: 1.4,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(Orders? order) {
    final eta = order?.expectedDeliveryDate;
    final hasEta = eta != null && eta.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: screenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              color: primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEta ? 'التوصيل المتوقع' : 'حالة التوصيل',
                  style: textBold.copyWith(
                    fontSize: 13,
                    color: primaryText,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasEta ? eta : 'سيتم تحديث حالة التوصيل عند تجهيز الطلب.',
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: secondaryText,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsPreview(List<OrderDetailsModel> items) {
    final previewItems = items.take(3).toList();
    final remainingCount = items.length - previewItems.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المنتجات (${items.length})',
                style: textBold.copyWith(
                  fontSize: 15,
                  color: primaryText,
                  fontFamily: 'AllineTajawal',
                ),
              ),
              if (remainingCount > 0)
                InkWell(
                  onTap: () {
                    final id = int.tryParse(_selectedOrderId) ?? 0;
                    RouterHelper.getOrderDetailsScreenRoute(orderId: id);
                  },
                  child: Text(
                    'عرض جميع المنتجات ($remainingCount+)',
                    style: textBold.copyWith(
                      fontSize: 12,
                      color: primaryBlue,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewItems.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: cardBorder, height: 1),
            ),
            itemBuilder: (context, index) {
              final item = previewItems[index];
              final imgUrl = item.productDetails?.thumbnailFullUrl?.path ?? '';
              final name = item.productDetails?.name ?? 'منتج';
              final qty = item.qty ?? 1;
              final price = item.price ?? 0;

              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: screenBg,
                      child: CustomImageWidget(
                        image: imgUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textMedium.copyWith(
                            fontSize: 13,
                            color: primaryText,
                            fontFamily: 'AllineTajawal',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '× $qty',
                              style: textBold.copyWith(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              PriceConverter.convertPrice(context, price),
                              style: textBold.copyWith(
                                fontSize: 13,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: successBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: successGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحتاج مساعدة؟',
                  style: textBold.copyWith(
                    fontSize: 13,
                    color: primaryText,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
                Text(
                  'فريق خدمة عملاء Alline جاهز لمساعدتك',
                  style: textRegular.copyWith(
                    fontSize: 11,
                    color: secondaryText,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openWhatsApp(_selectedOrderId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: successBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: successGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/whatsapp_official.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'واتساب',
                    style: textBold.copyWith(
                      fontSize: 12,
                      color: successGreen,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary: Track order
        ElevatedButton(
          onPressed: () {
            if (_selectedOrderId.isNotEmpty) {
              RouterHelper.getTrackingResultRoute(orderID: _selectedOrderId);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'تتبع الطلب',
            style: textBold.copyWith(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary: View order details
        OutlinedButton(
          onPressed: () {
            final id = int.tryParse(_selectedOrderId) ?? 0;
            if (id > 0) {
              RouterHelper.getOrderDetailsScreenRoute(orderId: id);
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            side: const BorderSide(color: primaryBlue, width: 1.2),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'عرض تفاصيل الطلب',
            style: textBold.copyWith(
              fontSize: 15,
              color: primaryBlue,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Tertiary: Return to home
        TextButton(
          onPressed: () {
            RouterHelper.getDashboardRoute(
              action: RouteAction.pushReplacement,
              page: 'home',
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: secondaryText,
            minimumSize: const Size(double.infinity, 44),
          ),
          child: Text(
            'العودة للرئيسية',
            style: textMedium.copyWith(
              fontSize: 14,
              color: secondaryText,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  double _calculateSubtotal(Orders? order, List<OrderDetailsModel> items) {
    if (items.isNotEmpty) {
      return items.fold<double>(
        0,
        (sum, item) => sum + ((item.price ?? 0) * (item.qty ?? 1)),
      );
    }
    final total = order?.orderAmount ?? 0;
    final discount = (order?.discountAmount ?? 0) + (order?.extraDiscount ?? 0);
    final shipping = order?.shippingCost ?? 0;
    return (total + discount - shipping).clamp(0, double.infinity);
  }

  String _formatPaymentMethodName(String key) {
    final lower = key.toLowerCase();
    if (lower == 'wallet') return 'رصيد محفظة Alline';
    if (lower.contains('jeeb') || lower.contains('جيب')) return 'محفظة جيب';
    if (lower.contains('jawali') || lower.contains('جوالي'))
      return 'محفظة جوالي';
    if (lower.contains('one_cash') ||
        lower.contains('onecash') ||
        lower.contains('ون كاش') ||
        lower.contains('ونكاش')) return 'محفظة ون كاش';
    if (lower.contains('floosak') || lower.contains('فلوسك'))
      return 'محفظة فلوسك';
    if (lower.contains('cash_wallet') ||
        lower.contains('كاش') && !lower.contains('استلام')) return 'محفظة كاش';
    if (lower.contains('cash') || lower.contains('cod'))
      return 'الدفع عند الاستلام';
    if (lower.contains('offline')) return 'المحافظ المحلية';
    return key.isNotEmpty ? key : 'الدفع عند الاستلام';
  }

  String _mapOrderStatusToArabic(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'تم استلام الطلب';
      case 'confirmed':
        return 'تم تأكيد الطلب';
      case 'processing':
        return 'قيد التجهيز';
      case 'out_for_delivery':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'returned':
        return 'تم إرجاع الطلب';
      case 'canceled':
      case 'cancelled':
        return 'تم الإلغاء';
      case 'failed':
        return 'فشل الطلب';
      default:
        return 'تم استلام الطلب';
    }
  }

  Color _getOrderStatusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
      case 'confirmed':
        return successBg;
      case 'processing':
      case 'out_for_delivery':
        return const Color(0xFFE8F1FC);
      case 'canceled':
      case 'cancelled':
      case 'failed':
        return const Color(0xFFFDE8E8);
      default:
        return const Color(0xFFFFF9E6);
    }
  }

  Color _getOrderStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
      case 'confirmed':
        return successGreen;
      case 'processing':
      case 'out_for_delivery':
        return primaryBlue;
      case 'canceled':
      case 'cancelled':
      case 'failed':
        return AllineColors.error;
      default:
        return const Color(0xFFD97706);
    }
  }
}
