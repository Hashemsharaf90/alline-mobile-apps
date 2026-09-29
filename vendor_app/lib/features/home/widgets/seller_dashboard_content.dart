import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/pos_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/stock_out_product_screen.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

/// Read-only composition of the existing seller controllers. No network work is
/// started here, so rebuilding a section cannot trigger duplicate requests.
class SellerDashboardContent extends StatelessWidget {
  const SellerDashboardContent({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Consumer5<ProfileController, ShopController, BankInfoController,
        OrderController, ProductController>(
      builder: (context, profile, shop, bank, orders, products, _) {
        final analytics = bank.dashboardTodayAnalytics;
        final actions = bank.dashboardActionAnalytics;
        final totalOrders = analytics == null
            ? null
            : (analytics.pending ?? 0) +
                (analytics.confirmed ?? 0) +
                (analytics.processing ?? 0) +
                (analytics.outForDelivery ?? 0) +
                (analytics.delivered ?? 0) +
                (analytics.canceled ?? 0) +
                (analytics.returned ?? 0) +
                (analytics.failed ?? 0);
        final lowStock = products.stockLimitStatus?.productCount ?? 0;
        final recentOrders =
            orders.dashboardRecentOrders?.orders?.take(4).toList();
        final topProducts =
            products.topSellingProductModel?.products?.take(3).toList();
        final name = (profile.userInfoModel?.fName ?? '').trim();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.isEmpty ? 'مرحبًا بك 👋' : 'مرحبًا، $name 👋',
                style: _style(context, 22, bold: true)),
            const SizedBox(height: 3),
            Text('إليك ملخص متجرك اليوم',
                style: _style(context, 14, muted: true)),
            const SizedBox(height: 18),
            _storeStatus(context, shop),
            const SizedBox(height: 14),
            _salesCard(context, bank, totalOrders, analytics?.pending,
                analytics?.delivered),
            const SizedBox(height: 24),
            _heading(context, 'يحتاج إلى انتباهك'),
            const SizedBox(height: 10),
            if (actions == null && products.stockLimitStatus == null)
              _information(context, 'بيانات التنبيهات غير متاحة حاليًا')
            else if ((actions?.pending ?? 0) == 0 &&
                (actions?.processing ?? 0) == 0 &&
                lowStock == 0)
              _information(context, 'كل شيء على ما يرام، لا توجد مهام عاجلة')
            else
              _panel(
                  context,
                  Column(children: [
                    if ((actions?.pending ?? 0) > 0)
                      _actionRow(
                          context,
                          Icons.receipt_long_outlined,
                          '${actions!.pending} طلبات جديدة',
                          'مراجعة الطلبات',
                          AllineColors.error,
                          () => _openOrders(context, 1)),
                    if ((actions?.processing ?? 0) > 0)
                      _actionRow(
                          context,
                          Icons.inventory_2_outlined,
                          '${actions!.processing} طلبات قيد التجهيز',
                          'متابعة التجهيز',
                          AllineColors.warning,
                          () => _openOrders(context, 2)),
                    if (lowStock > 0)
                      _actionRow(
                          context,
                          Icons.warning_amber_rounded,
                          '$lowStock منتجات منخفضة المخزون',
                          'إدارة المخزون',
                          AllineColors.orange,
                          () => _push(context, const StockOutProductScreen())),
                  ])),
            const SizedBox(height: 24),
            _heading(context, 'إجراءات سريعة'),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final width = (constraints.maxWidth - 10) / 2;
              final actions = <Widget>[
                _quick(
                    context,
                    width,
                    Icons.add_box_outlined,
                    'إضافة منتج',
                    () => _push(
                        context, const AddProductTabView(fromHome: true))),
                _quick(context, width, Icons.receipt_long_outlined, 'الطلبات',
                    () => _openOrders(context, 0)),
                _quick(context, width, Icons.inventory_2_outlined, 'المخزون',
                    () => _push(context, const StockOutProductScreen())),
                _quick(context, width, Icons.account_balance_wallet_outlined,
                    'المحفظة', () => _push(context, const WalletScreen())),
                if (profile.userInfoModel?.posActive == 1)
                  _quick(context, width, Icons.point_of_sale_rounded,
                      'نقطة البيع', () => _push(context, const PosScreen())),
                _quick(context, width, Icons.chat_bubble_outline, 'الرسائل',
                    () => _push(context, const InboxScreen())),
              ];
              return Wrap(spacing: 10, runSpacing: 10, children: actions);
            }),
            if (profile.userInfoModel?.productCount == 0) ...[
              const SizedBox(height: 12),
              _panel(
                  context,
                  Row(children: [
                    Expanded(
                        child: Text('ابدأ بإضافة أول منتج إلى متجرك',
                            style: _style(context, 13, muted: true))),
                    TextButton(
                      onPressed: () => _push(
                          context, const AddProductTabView(fromHome: true)),
                      child: const Text('إضافة منتج'),
                    ),
                  ])),
            ],
            const SizedBox(height: 24),
            _heading(context, 'آخر الطلبات',
                action: 'عرض الكل', onAction: () => _openOrders(context, 0)),
            const SizedBox(height: 10),
            if (recentOrders == null)
              _information(context, 'تعذر تحميل الطلبات',
                  retry: () => context
                      .read<OrderController>()
                      .getDashboardRecentOrders())
            else if (recentOrders.isEmpty)
              _information(
                  context, 'لا توجد طلبات بعد\nستظهر طلباتك الجديدة هنا')
            else
              _panel(
                  context,
                  Column(children: [
                    for (final order in recentOrders) _orderRow(context, order),
                  ])),
            const SizedBox(height: 24),
            _heading(context, 'أداء الأرباح',
                action: 'التفاصيل', onAction: () => onNavigate(3)),
            const SizedBox(height: 10),
            _earningsPanel(context, bank),
            const SizedBox(height: 24),
            _heading(context, 'المخزون يحتاج انتباهك'),
            const SizedBox(height: 10),
            _inventoryPanel(context, products),
            const SizedBox(height: 24),
            if (topProducts != null && topProducts.isNotEmpty) ...[
              _heading(context, 'الأكثر مبيعًا',
                  action: 'عرض المنتجات', onAction: () => onNavigate(2)),
              const SizedBox(height: 10),
              _panel(
                  context,
                  Column(children: [
                    for (var i = 0; i < topProducts.length; i++)
                      _topProductRow(
                          context,
                          i + 1,
                          topProducts[i].product?.name ?? 'منتج',
                          topProducts[i].count ?? '0',
                          topProducts[i].product?.thumbnailFullUrl?.path),
                  ])),
              const SizedBox(height: 24),
            ],
            _heading(context, 'محفظتك',
                action: 'عرض المحفظة',
                onAction: () => _push(context, const WalletScreen())),
            const SizedBox(height: 10),
            _walletPanel(context, profile),
          ]),
        );
      },
    );
  }

  TextStyle _style(BuildContext context, double size,
          {bool bold = false, bool muted = false}) =>
      TextStyle(
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: muted
              ? ColorResources.getTextSubTitle(context)
              : ColorResources.getTextTitle(context),
          height: 1.35);

  Widget _panel(BuildContext context, Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: ColorResources.getCardBg(context),
          border: Border.all(color: ColorResources.getBorder(context)),
          borderRadius: BorderRadius.circular(16)),
      child: child);

  Widget _heading(BuildContext context, String title,
          {String? action, VoidCallback? onAction}) =>
      Row(children: [
        Expanded(child: Text(title, style: _style(context, 17, bold: true))),
        if (action != null)
          TextButton(
              onPressed: onAction,
              child: Text(action,
                  style: const TextStyle(
                      color: AllineColors.primary,
                      fontWeight: FontWeight.w700)))
      ]);

  Widget _storeStatus(BuildContext context, ShopController shop) {
    final model = shop.shopModel;
    // ShopModel.temporaryClose currently stores the inverted backend flag:
    // true means accepting orders, false means temporarily closed.
    final open = model?.temporaryClose == true && model?.vacationStatus != true;
    final status = model == null
        ? 'حالة المتجر غير متاحة'
        : model.vacationStatus == true
            ? 'متجرك في إجازة'
            : open
                ? 'متجرك مفتوح'
                : 'متجرك مغلق مؤقتًا';
    return _panel(
        context,
        Semantics(
            button: model != null,
            label: status,
            child: InkWell(
                onTap: model == null ? null : () => _statusSheet(context, shop),
                child: Row(children: [
                  Icon(
                      open
                          ? Icons.storefront_rounded
                          : Icons.store_mall_directory_outlined,
                      color: open ? AllineColors.success : AllineColors.warning,
                      size: 25),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(status, style: _style(context, 15, bold: true)),
                        Text(
                            model == null
                                ? 'اسحب للتحديث'
                                : open
                                    ? 'يستقبل الطلبات الآن'
                                    : 'اضغط لإدارة حالة المتجر',
                            style: _style(context, 12, muted: true)),
                      ])),
                  if (model != null)
                    const Icon(Icons.chevron_left_rounded,
                        color: AllineColors.primary),
                ]))));
  }

  Widget _salesCard(BuildContext context, BankInfoController bank,
      int? totalOrders, int? pending, int? delivered) {
    final sales = bank.todaySales;
    final yesterday = bank.yesterdaySales;
    final difference = sales != null && yesterday != null && yesterday > 0
        ? (sales - yesterday) / yesterday * 100
        : null;
    return _panel(
        context,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.trending_up_rounded,
                color: AllineColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('قيمة الطلبات المدفوعة اليوم',
                style: _style(context, 14, muted: true))
          ]),
          const SizedBox(height: 8),
          Text(
              sales == null
                  ? 'غير متاحة'
                  : PriceConverter.convertPrice(context, sales),
              style: _style(context, 24, bold: true)),
          const SizedBox(height: 3),
          Text(
              sales == null
                  ? 'تعذر جلب بيانات المبيعات'
                  : difference == null
                      ? 'الطلبات المدفوعة التي أُنشئت اليوم'
                      : '${difference >= 0 ? '↑' : '↓'} ${difference.abs().toStringAsFixed(0)}% مقارنة بالأمس',
              style: _style(context, 12, muted: true)),
          const SizedBox(height: 14),
          Divider(color: ColorResources.getBorder(context), height: 1),
          const SizedBox(height: 12),
          Row(children: [
            _metric(context, 'الطلبات', totalOrders),
            _metric(context, 'الجديدة', pending),
            _metric(context, 'المكتملة', delivered),
          ]),
        ]));
  }

  Widget _metric(BuildContext context, String title, int? value) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value?.toString() ?? '—', style: _style(context, 18, bold: true)),
        Text(title, style: _style(context, 12, muted: true)),
      ]));

  Widget _information(BuildContext context, String message,
          {VoidCallback? retry}) =>
      _panel(
          context,
          Row(children: [
            Expanded(
                child: Text(message, style: _style(context, 13, muted: true))),
            if (retry != null)
              TextButton(onPressed: retry, child: const Text('إعادة المحاولة')),
          ]));

  Widget _actionRow(BuildContext context, IconData icon, String title,
          String action, Color color, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Row(children: [
                Icon(icon, color: color, size: 21),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(title, style: _style(context, 13, bold: true))),
                Text(action,
                    style: const TextStyle(
                        color: AllineColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ])));

  Widget _quick(BuildContext context, double width, IconData icon, String label,
          VoidCallback onTap) =>
      SizedBox(
          width: width,
          child: Material(
              color: ColorResources.getCardBg(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: ColorResources.getBorder(context))),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 66),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(children: [
                            Icon(icon, color: AllineColors.primary, size: 23),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(label,
                                    style: _style(context, 14, bold: true),
                                    maxLines: 2))
                          ]))))));

  Widget _orderRow(BuildContext context, Order order) {
    final customer =
        '${order.customer?.fName ?? ''} ${order.customer?.lName ?? ''}'.trim();
    final label = switch (order.orderStatus) {
      'pending' => 'جديد',
      'confirmed' => 'مؤكد',
      'processing' => 'قيد التجهيز',
      'out_for_delivery' => 'في الطريق',
      'delivered' => 'مكتمل',
      'canceled' => 'ملغي',
      'returned' => 'مرتجع',
      _ => order.orderStatus ?? 'غير معروف',
    };
    final createdAt = DateTime.tryParse(order.createdAt ?? '')?.toLocal();
    final time = createdAt == null
        ? ''
        : '${createdAt.day}/${createdAt.month} • ${TimeOfDay.fromDateTime(createdAt).format(context)}';
    return InkWell(
        onTap: () => _push(context, OrderDetailsScreen(orderId: order.id)),
        child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: Row(children: [
              const Icon(Icons.receipt_long_outlined,
                  color: AllineColors.primary),
              const SizedBox(width: 11),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('طلب #${order.id}',
                        style: _style(context, 14, bold: true)),
                    Text(customer.isEmpty ? 'عميل' : customer,
                        style: _style(context, 12, muted: true), maxLines: 1),
                    if (time.isNotEmpty)
                      Text(time, style: _style(context, 11, muted: true)),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                    PriceConverter.convertPrice(
                        context, order.orderAmount ?? 0),
                    style: _style(context, 13, bold: true)),
                Text(label, style: _style(context, 11, muted: true)),
              ]),
            ])));
  }

  Widget _earningsPanel(BuildContext context, BankInfoController bank) {
    final points = bank.dashboardWeekEarnings;
    if (points == null || points.isEmpty) {
      return _information(context, 'لا توجد بيانات كافية لعرض الإحصائيات');
    }
    final values = points;
    final maxValue =
        values.fold<double>(0, (max, value) => value > max ? value : max);
    return _panel(
        context,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('أرباح هذا الأسبوع', style: _style(context, 13, muted: true)),
          const SizedBox(height: 16),
          SizedBox(
              height: 76,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (final value in values)
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                              height:
                                  maxValue == 0 ? 4 : 4 + 72 * value / maxValue,
                              decoration: BoxDecoration(
                                  color: AllineColors.primary
                                      .withValues(alpha: value == 0 ? .18 : .8),
                                  borderRadius: BorderRadius.circular(4))))),
              ])),
          const SizedBox(height: 9),
          Text('الأرباح الفعلية من بيانات المتجر',
              style: _style(context, 12, muted: true)),
        ]));
  }

  Widget _inventoryPanel(BuildContext context, ProductController products) {
    final list = products.stockOutProductList;
    if (list == null) return _information(context, 'تعذر تحميل حالة المخزون');
    if (list.isEmpty) {
      return _information(context, 'لا توجد منتجات منخفضة المخزون');
    }
    return _panel(
        context,
        Column(children: [
          for (final product in list.take(3))
            InkWell(
                onTap: () =>
                    _push(context, ProductDetailsScreen(productModel: product)),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Row(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                              width: 36,
                              height: 36,
                              child: product
                                          .thumbnailFullUrl?.path?.isNotEmpty ==
                                      true
                                  ? Image.network(
                                      product.thumbnailFullUrl!.path!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.inventory_2_outlined,
                                          color: AllineColors.orange))
                                  : const Icon(Icons.inventory_2_outlined,
                                      color: AllineColors.orange))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(product.name ?? 'منتج',
                              style: _style(context, 13, bold: true),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      Text(
                          product.currentStock == 0
                              ? 'نفد'
                              : 'المتبقي ${product.currentStock ?? '—'}',
                          style: _style(context, 12, muted: true)),
                    ]))),
          Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                  onPressed: () =>
                      _push(context, const StockOutProductScreen()),
                  child: const Text('إدارة المخزون'))),
        ]));
  }

  Widget _topProductRow(BuildContext context, int rank, String name,
          String count, String? imageUrl) =>
      ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Row(children: [
            Text('$rank', style: _style(context, 14, bold: true)),
            const SizedBox(width: 10),
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_outlined))
                      : const Icon(Icons.image_outlined),
                )),
            const SizedBox(width: 10),
            Expanded(
                child: Text(name,
                    style: _style(context, 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            Text('$count مبيعًا', style: _style(context, 12, muted: true))
          ]));

  Widget _walletPanel(BuildContext context, ProfileController profile) {
    final wallet = profile.userInfoModel?.wallet;
    if (wallet == null) {
      return _information(context, 'بيانات المحفظة غير متاحة');
    }
    return _panel(
        context,
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('إجمالي الأرباح', style: _style(context, 12, muted: true)),
                Text(
                    PriceConverter.convertPrice(
                        context, wallet.totalEarning ?? 0),
                    style: _style(context, 17, bold: true)),
              ])),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('السحب المعلق', style: _style(context, 12, muted: true)),
                Text(
                    PriceConverter.convertPrice(
                        context, wallet.pendingWithdraw ?? 0),
                    style: _style(context, 15, bold: true)),
              ])),
        ]));
  }

  void _openOrders(BuildContext context, int tab) {
    context.read<OrderController>().setIndex(context, tab);
    onNavigate(1);
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _statusSheet(BuildContext context, ShopController shop) {
    final open = shop.shopModel?.temporaryClose == true;
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: ColorResources.getCardBg(context),
        builder: (sheetContext) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('حالة المتجر',
                          style: _style(context, 18, bold: true)),
                      const SizedBox(height: 14),
                      FilledButton(
                          onPressed: () {
                            shop.shopTemporaryClose(sheetContext, open ? 1 : 0);
                          },
                          child: Text(
                              open ? 'إغلاق المتجر مؤقتًا' : 'فتح المتجر')),
                      const SizedBox(height: 8),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _push(context, const VacationModeScreen());
                          },
                          child: const Text('إعدادات الإجازة')),
                    ]))));
  }
}
