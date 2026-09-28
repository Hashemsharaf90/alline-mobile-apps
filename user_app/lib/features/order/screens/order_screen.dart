import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/order_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/order_type_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/order_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromDashboard;
  final bool fromPlaceOrder;

  const OrderScreen({
    super.key,
    this.isBacButtonExist = true,
    this.fromDashboard = false,
    this.fromPlaceOrder = false,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late bool _isGuestMode;

  @override
  void initState() {
    super.initState();
    _isGuestMode = !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn();

    if (!_isGuestMode) {
      final orderCtrl = Provider.of<OrderController>(context, listen: false);
      orderCtrl.setIndex(0, notify: false);
      orderCtrl.getOrderList(1, 'all');

      // Pre-load global shopping requests
      Provider.of<GlobalShoppingController>(context, listen: false).getMyRequests();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeController>(context).darkTheme;
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromPlaceOrder) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF4F8FE),
        appBar: _buildAppBar(context, isDark, isLtr),
        body: _isGuestMode
            ? NotLoggedInWidget(
                message: getTranslated('to_view_the_order_history', context),
                fromPage: widget.fromDashboard
                    ? '${RouterHelper.dashboardScreen}?page=orders'
                    : RouterHelper.orderScreen,
              )
            : RefreshIndicator(
                color: AllineColors.primary,
                onRefresh: () async {
                  final orderCtrl = Provider.of<OrderController>(context, listen: false);
                  if (orderCtrl.orderTypeIndex == 4) {
                    await Provider.of<GlobalShoppingController>(context, listen: false).getMyRequests();
                  } else {
                    await orderCtrl.getOrderList(1, orderCtrl.selectedType, refresh: true);
                  }
                },
                child: Column(
                  children: [
                    // Search & Filters Header
                    _buildSearchAndFilters(context, isDark, isLtr),

                    // Main Orders Content
                    Expanded(
                      child: Consumer2<OrderController, GlobalShoppingController>(
                        builder: (context, orderCtrl, globalCtrl, child) {
                          // Tab 4: Global Shopping Requests
                          if (orderCtrl.orderTypeIndex == 4) {
                            return _buildGlobalShoppingTab(context, globalCtrl, isDark, isLtr);
                          }

                          // Tabs 0-3: Local Marketplace & Supermarket Orders
                          if (orderCtrl.orderModel == null) {
                            return const OrderShimmerWidget();
                          }

                          final List<Orders> allOrders = orderCtrl.orderModel?.orders ?? [];

                          // Filter in-memory by search query
                          final List<Orders> filteredOrders = _filterOrders(allOrders, _searchQuery);

                          if (filteredOrders.isEmpty) {
                            return _buildEmptyStateForFilters(context, orderCtrl, isLtr);
                          }

                          return SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: PaginatedListView(
                              scrollController: _scrollController,
                              onPaginate: (int? offset) async {
                                await orderCtrl.getOrderList(offset!, orderCtrl.selectedType);
                              },
                              totalSize: orderCtrl.orderModel?.totalSize,
                              offset: orderCtrl.orderModel?.offset != null
                                  ? int.parse(orderCtrl.orderModel!.offset!)
                                  : 1,
                              itemView: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(top: 6, bottom: 24),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  return OrderWidget(orderModel: filteredOrders[index]);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, bool isLtr) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? Theme.of(context).dividerColor.withValues(alpha: 0.1) : const Color(0xFFE1E8F2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Back Button (only when isBacButtonExist is true and not from bottom nav)
                if (widget.isBacButtonExist) ...[
                  InkWell(
                    onTap: () {
                      if (widget.fromPlaceOrder) {
                        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF4F8FE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE1E8F2), width: 0.8),
                      ),
                      child: Icon(
                        isLtr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDark ? Colors.white : const Color(0xFF071B49),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Title
                Text(
                  isLtr ? 'My Orders' : 'طلباتي',
                  style: titilliumBold.copyWith(
                    fontSize: 19,
                    color: isDark ? Colors.white : const Color(0xFF071B49),
                  ),
                ),

                const Spacer(),

                // Quick Refresh Button
                InkWell(
                  onTap: () {
                    final orderCtrl = Provider.of<OrderController>(context, listen: false);
                    if (orderCtrl.orderTypeIndex == 4) {
                      Provider.of<GlobalShoppingController>(context, listen: false).getMyRequests();
                    } else {
                      orderCtrl.getOrderList(1, orderCtrl.selectedType, refresh: true);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF4F8FE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE1E8F2), width: 0.8),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: AllineColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SEARCH BAR & FILTER CHIPS ---
  Widget _buildSearchAndFilters(BuildContext context, bool isDark, bool isLtr) {
    return Container(
      color: isDark ? Theme.of(context).cardColor : Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Consumer<OrderController>(
            builder: (context, orderCtrl, _) => _buildOrdersSummary(
              context,
              orderCtrl.orderModel?.orders ?? const <Orders>[],
              isDark,
              isLtr,
            ),
          ),
          const SizedBox(height: 10),
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF4F8FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Theme.of(context).dividerColor.withValues(alpha: 0.2) : const Color(0xFFE1E8F2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: titilliumRegular.copyWith(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF071B49),
                ),
                decoration: InputDecoration(
                  hintText: isLtr
                      ? 'Search by order #, store, or product...'
                      : 'ابحث برقم الطلب، المتجر، أو المنتج...',
                  hintStyle: titilliumRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF6D85AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF6D85AF),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6D85AF)),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                OrderTypeButton(
                  text: isLtr ? 'All' : 'الكل',
                  index: 0,
                  icon: Icons.grid_view_rounded,
                ),
                const SizedBox(width: 8),
                OrderTypeButton(
                  text: isLtr ? 'Active' : 'جارية',
                  index: 1,
                  icon: Icons.two_wheeler_rounded,
                ),
                const SizedBox(width: 8),
                OrderTypeButton(
                  text: isLtr ? 'Delivered' : 'مكتملة',
                  index: 2,
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(width: 8),
                OrderTypeButton(
                  text: isLtr ? 'Canceled' : 'ملغاة',
                  index: 3,
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(width: 8),
                OrderTypeButton(
                  text: isLtr ? 'Global Shopping 🌍' : 'تسوق عالمي 🌍',
                  index: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSummary(
    BuildContext context,
    List<Orders> orders,
    bool isDark,
    bool isLtr,
  ) {
    final activeStatuses = {
      'pending',
      'confirmed',
      'processing',
      'out_for_delivery',
    };
    final activeCount = orders.where((order) => activeStatuses.contains(order.orderStatus?.toLowerCase())).length;
    final deliveredCount = orders.where((order) => order.orderStatus?.toLowerCase() == 'delivered').length;
    final labels = isLtr ? ['All', 'Active', 'Delivered'] : ['الكل', 'جارية', 'مكتملة'];
    final values = [orders.length, activeCount, deliveredCount];
    final icons = [Icons.receipt_long_rounded, Icons.local_shipping_rounded, Icons.check_circle_rounded];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Row(
        children: List.generate(labels.length, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == labels.length - 1 ? 0 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF4F8FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE1E8F2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[index], size: 16, color: index == 1 ? AllineColors.accent : AllineColors.primary),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${values[index]}', style: titilliumBold.copyWith(fontSize: 16, color: isDark ? Colors.white : const Color(0xFF071B49))),
                      Text(labels[index], style: titilliumRegular.copyWith(fontSize: 10, color: const Color(0xFF6D85AF))),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- FILTER HELPER ---
  List<Orders> _filterOrders(List<Orders> orders, String query) {
    if (query.isEmpty) return orders;

    final q = query.toLowerCase();
    return orders.where((order) {
      final idStr = (order.id ?? '').toString();
      final alnStr = '#aln-$idStr';
      final shopName = (order.seller?.shop?.name ?? '').toLowerCase();
      final status = (order.orderStatus ?? '').toLowerCase();

      bool productMatches = false;
      if (order.details != null) {
        for (var detail in order.details!) {
          final pName = detail.product?.thumbnail?.toLowerCase() ?? '';
          if (pName.contains(q)) {
            productMatches = true;
            break;
          }
        }
      }

      return idStr.contains(q) ||
          alnStr.contains(q) ||
          shopName.contains(q) ||
          status.contains(q) ||
          productMatches;
    }).toList();
  }

  // --- GLOBAL SHOPPING TAB VIEW ---
  Widget _buildGlobalShoppingTab(
      BuildContext context, GlobalShoppingController globalCtrl, bool isDark, bool isLtr) {
    if (globalCtrl.isRequestsLoading) {
      return const OrderShimmerWidget();
    }

    final requests = globalCtrl.requestsList;

    if (requests.isEmpty) {
      return _buildEmptyState(
        context: context,
        icon: Icons.flight_takeoff_rounded,
        title: isLtr
            ? 'No Global Shopping Requests'
            : 'ليس لديك أي طلبات شراء عالمية حتى الآن',
        subtitle: isLtr
            ? 'Request any product from Amazon, Shein, or international stores and we deliver it to your door in Yemen.'
            : 'اطلب أي منتج من المواقع العالمية مثل أمازون وشي إن ونحن نتكفل بشرائه وتوصيله إلى باب بيتك في اليمن.',
        buttonText: isLtr ? 'New Global Request' : 'طلب شراء دولي جديد',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GlobalShoppingScreen()),
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return _buildGlobalRequestCard(context, req, isDark, isLtr);
      },
    );
  }

  // --- GLOBAL SHOPPING REQUEST CARD ---
  Widget _buildGlobalRequestCard(
      BuildContext context, GlobalShoppingRequestModel req, bool isDark, bool isLtr) {
    Color statusBg;
    Color statusText;
    String statusTitle;

    switch (req.status) {
      case 'priced':
      case 'approved':
        statusBg = const Color(0xFFE8F8EE);
        statusText = AllineColors.success;
        statusTitle = isLtr ? 'Priced - Ready' : 'تم التسعير - جاهز للشراء';
        break;
      case 'ordered':
      case 'shipped':
        statusBg = const Color(0xFFEBF3FC);
        statusText = AllineColors.primary;
        statusTitle = isLtr ? 'Purchased & Shipping ✈️' : 'تم الشراء وجاري الشحن الدولي ✈️';
        break;
      case 'delivered':
        statusBg = const Color(0xFFE8F8EE);
        statusText = AllineColors.success;
        statusTitle = isLtr ? 'Delivered' : 'تم التسليم بنجاح';
        break;
      default:
        statusBg = const Color(0xFFFFF8EC);
        statusText = AllineColors.accent;
        statusTitle = isLtr ? 'Under Pricing ⏳' : 'قيد المراجعة والتسعير ⏳';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Theme.of(context).dividerColor.withValues(alpha: 0.1) : const Color(0xFFE1E8F2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071B49).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9D5FF), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'تسوق عالمي',
                      style: titilliumBold.copyWith(fontSize: 11, color: const Color(0xFF7C3AED)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusTitle,
                  style: titilliumBold.copyWith(fontSize: 11, color: statusText),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Request ID & Date
          Row(
            children: [
              Text(
                '#REQ-${req.id ?? ''}',
                style: titilliumBold.copyWith(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF071B49),
                ),
              ),
              const Spacer(),
              if (req.createdAt != null)
                Text(
                  req.createdAt!.length > 10 ? req.createdAt!.substring(0, 10) : req.createdAt!,
                  style: titilliumRegular.copyWith(fontSize: 11, color: const Color(0xFF6D85AF)),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Store & Product details
          Row(
            children: [
              const Icon(Icons.language_rounded, size: 14, color: Color(0xFF6D85AF)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${req.storeName ?? "Global Store"} • ${isLtr ? "Qty" : "الكمية"}: ${req.quantity ?? 1}',
                  style: textMedium.copyWith(fontSize: 12, color: const Color(0xFF6D85AF)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (req.productUrl != null && req.productUrl!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              req.productUrl!,
              style: titilliumRegular.copyWith(
                fontSize: 11,
                color: AllineColors.primary,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Theme.of(context).dividerColor.withValues(alpha: 0.08) : const Color(0xFFF0F4FA),
          ),
          const SizedBox(height: 12),

          // Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLtr ? 'Quoted Price' : 'السعر المعتمد',
                    style: titilliumRegular.copyWith(fontSize: 11, color: const Color(0xFF6D85AF)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (req.approvedPrice != null && req.approvedPrice! > 0)
                        ? PriceConverter.convertPrice(context, req.approvedPrice)
                        : (isLtr ? 'Pending Pricing' : 'بانتظار التسعير'),
                    style: titilliumBold.copyWith(
                      fontSize: 14,
                      color: (req.approvedPrice != null && req.approvedPrice! > 0)
                          ? AllineColors.primary
                          : AllineColors.accent,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AllineColors.primary.withValues(alpha: 0.05),
                  side: const BorderSide(color: AllineColors.primary, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isLtr ? 'View Request' : 'عرض الطلب',
                  style: titilliumBold.copyWith(fontSize: 12, color: AllineColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATES FOR FILTERS ---
  Widget _buildEmptyStateForFilters(
      BuildContext context, OrderController orderCtrl, bool isLtr) {
    // 1. Search Query Empty State
    if (_searchQuery.isNotEmpty) {
      return _buildEmptyState(
        context: context,
        icon: Icons.search_off_rounded,
        title: isLtr ? 'No Matching Orders' : 'لم نجد أي طلب يطابق بحثك',
        subtitle: isLtr
            ? 'Check the order number, store name, or clear search.'
            : 'تأكد من كتابة رقم الطلب أو اسم المتجر بشكل صحيح.',
        buttonText: isLtr ? 'Clear Search' : 'مسح البحث',
        onPressed: () {
          setState(() {
            _searchController.clear();
            _searchQuery = '';
          });
        },
      );
    }

    // 2. Filter Specific Empty States
    if (orderCtrl.orderTypeIndex == 1) {
      return _buildEmptyState(
        context: context,
        icon: Icons.two_wheeler_rounded,
        title: isLtr ? 'No Active Orders' : 'لا توجد طلبات جارية',
        subtitle: isLtr
            ? 'You have no orders currently in progress.'
            : 'ليس لديك أي طلبات قيد التجهيز أو التوصيل في الوقت الحالي.',
        buttonText: isLtr ? 'View All Orders' : 'عرض جميع الطلبات',
        onPressed: () => orderCtrl.setIndex(0),
      );
    } else if (orderCtrl.orderTypeIndex == 2) {
      return _buildEmptyState(
        context: context,
        icon: Icons.check_circle_outline_rounded,
        title: isLtr ? 'No Completed Orders' : 'لا توجد طلبات مكتملة',
        subtitle: isLtr
            ? 'You have no delivered orders yet.'
            : 'لم يتم تسليم أي طلبات لك حتى الآن.',
        buttonText: isLtr ? 'View All Orders' : 'عرض جميع الطلبات',
        onPressed: () => orderCtrl.setIndex(0),
      );
    } else if (orderCtrl.orderTypeIndex == 3) {
      return _buildEmptyState(
        context: context,
        icon: Icons.cancel_outlined,
        title: isLtr ? 'No Canceled Orders' : 'لا توجد طلبات ملغاة',
        subtitle: isLtr
            ? 'You have no canceled or returned orders.'
            : 'سجلك خالٍ من أي طلبات ملغاة أو مرتجعة.',
        buttonText: isLtr ? 'View All Orders' : 'عرض جميع الطلبات',
        onPressed: () => orderCtrl.setIndex(0),
      );
    }

    // 3. Global Empty State (User has no orders at all)
    return _buildEmptyState(
      context: context,
      icon: Icons.shopping_bag_outlined,
      title: isLtr ? 'No Orders Yet' : 'لا توجد لديك طلبات حتى الآن',
      subtitle: isLtr
          ? 'Explore thousands of products and deals on Alline and start shopping now!'
          : 'استكشف آلاف المنتجات والعروض المميزة في Alline وابدأ التسوق الآن!',
      buttonText: isLtr ? 'Start Shopping' : 'ابدأ التسوق الآن',
      onPressed: () {
        RouterHelper.getDashboardRoute(page: 'home');
      },
    );
  }

  // --- GENERIC EMPTY STATE BUILDER ---
  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AllineColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 38,
                color: AllineColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: titilliumBold.copyWith(
                fontSize: 17,
                color: isDark ? Colors.white : const Color(0xFF071B49),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                fontSize: 13,
                color: const Color(0xFF6D85AF),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AllineColors.primary,
                elevation: 0,
                minimumSize: const Size(180, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: titilliumBold.copyWith(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
