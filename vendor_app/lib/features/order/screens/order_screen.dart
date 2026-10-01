import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/order_widget.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_list_filter_bottomsheet_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromHome;
  const OrderScreen(
      {super.key, this.isBacButtonExist = false, this.fromHome = false});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  bool _isSearchOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    Provider.of<CustomerController>(Get.context!, listen: false)
        .resetCustomerId(isUpdate: false, customerId: -1);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      body: SafeArea(
        child: Consumer<OrderController>(
          builder: (context, orderController, _) {
            List<Order>? rawOrders = orderController.orderModel?.orders;
            List<Order>? filteredOrders;

            if (rawOrders != null) {
              if (_searchQuery.trim().isEmpty) {
                filteredOrders = rawOrders;
              } else {
                final q = _searchQuery.trim().toLowerCase();
                filteredOrders = rawOrders.where((order) {
                  final idStr = order.id?.toString() ?? '';
                  final customer =
                      '${order.customer?.fName ?? ''} ${order.customer?.lName ?? ''}'
                          .toLowerCase();
                  final phone = order.customer?.phone?.toLowerCase() ?? '';
                  return idStr.contains(q) ||
                      customer.contains(q) ||
                      phone.contains(q);
                }).toList();
              }
            }

            final totalOrdersCount =
                orderController.orderModel?.totalSize ?? filteredOrders?.length ?? 0;

            return Column(
              children: [
                // 1. Compact Premium Header
                _buildHeader(context, orderController),

                // 2. Expandable Search Box
                if (_isSearchOpen) _buildSearchBox(context),

                // 3. Compact Order Summary Bar
                _buildSummaryBar(context, totalOrdersCount, rawOrders),

                // 4. Horizontal Scroll Filter Tabs
                _buildFilterTabs(context, orderController),
                const SizedBox(height: 6),

                // 5. Orders List / Empty State / Shimmer Loading
                Expanded(
                  child: orderController.orderModel != null
                      ? (filteredOrders != null && filteredOrders.isNotEmpty)
                          ? RefreshIndicator(
                              onRefresh: () async {
                                await orderController.getOrderList(
                                  context,
                                  1,
                                  orderController.orderType,
                                  orderController.filterModel,
                                );
                              },
                              child: SingleChildScrollView(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 24),
                                child: PaginatedListViewWidget(
                                  reverse: false,
                                  scrollController: scrollController,
                                  totalSize: orderController.orderModel?.totalSize,
                                  offset: orderController.orderModel != null
                                      ? int.tryParse(orderController
                                              .orderModel!.offset
                                              .toString()) ??
                                          1
                                      : null,
                                  onPaginate: (int? offset) async {
                                    await orderController.getOrderList(
                                      context,
                                      offset!,
                                      orderController.orderType,
                                      orderController.filterModel,
                                      reload: false,
                                    );
                                  },
                                  itemView: ListView.builder(
                                    itemCount: filteredOrders.length,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return OrderWidget(
                                        orderModel: filteredOrders![index],
                                        index: index,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : _buildEmptyState(context, orderController)
                      : const OrderShimmer(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header with Search & Filter Actions
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, OrderController orderController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: ColorResources.getScaffoldBg(context),
      child: Row(
        children: [
          if (widget.isBacButtonExist) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              color: AllineColors.primary,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطلبات',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: ColorResources.getTextTitle(context),
                  ),
                ),
                Text(
                  'إدارة ومتابعة طلبات متجرك',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                ),
              ],
            ),
          ),

          // Search Toggle Button
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: AllineColors.primary,
              size: 24,
            ),
          ),

          // Filter Button with Badge
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const OrderListFilterBottomSheet(),
                  );
                },
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AllineColors.primary,
                  size: 22,
                ),
              ),
              if (orderController.isFilterActive)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AllineColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Input Container
  // ---------------------------------------------------------------------------

  Widget _buildSearchBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AllineColors.border),
        ),
        child: TextField(
          controller: searchController,
          autofocus: true,
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 14,
            color: ColorResources.getTextTitle(context),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'ابحث برقم الطلب أو اسم العميل...',
            hintStyle: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 13,
              color: ColorResources.getTextSubTitle(context),
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AllineColors.coolGray, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        size: 18, color: AllineColors.coolGray),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary Bar (Count & Quick Indicators)
  // ---------------------------------------------------------------------------

  Widget _buildSummaryBar(
      BuildContext context, int totalCount, List<Order>? orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '$totalCount طلبًا',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: ColorResources.getTextTitle(context),
            ),
          ),
          const Spacer(),
          if (orders != null && orders.isNotEmpty) ...[
            _indicatorPill(
              '${orders.where((o) => o.orderStatus == 'pending').length} جديدة',
              AllineColors.error,
              const Color(0xFFFEF2F2),
            ),
            const SizedBox(width: 6),
            _indicatorPill(
              '${orders.where((o) => o.orderStatus == 'processing' || o.orderStatus == 'confirmed').length} تجهيز',
              AllineColors.warning,
              const Color(0xFFFFFBEB),
            ),
            const SizedBox(width: 6),
            _indicatorPill(
              '${orders.where((o) => o.orderStatus == 'delivered').length} مكتملة',
              AllineColors.success,
              const Color(0xFFECFDF5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _indicatorPill(String text, Color textCol, Color bgCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'AllineTajawal',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Horizontal Filter Tabs
  // ---------------------------------------------------------------------------

  Widget _buildFilterTabs(
      BuildContext context, OrderController orderController) {
    final tabs = [
      (label: 'الكل', index: 0),
      (label: 'جديدة', index: 1),
      (label: 'قيد التجهيز', index: 2),
      (label: 'قيد التوصيل', index: 8),
      (label: 'مكتملة', index: 3),
      (label: 'ملغاة', index: 6),
      (label: 'مرتجعة', index: 4),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final tab = tabs[i];
            final isSelected = orderController.orderTypeIndex == tab.index;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                orderController.setIndex(context, tab.index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AllineColors.primary
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AllineColors.primary
                        : AllineColors.border,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AllineColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tab.label,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : ColorResources.getTextSubTitle(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State with Reset Filters
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(
      BuildContext context, OrderController orderController) {
    final bool hasFilterOrSearch =
        orderController.isFilterActive || _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AllineColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AllineColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hasFilterOrSearch
                ? 'لا توجد طلبات تطابق بحثك'
                : 'لا توجد طلبات حتى الآن',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ColorResources.getTextTitle(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilterOrSearch
                ? 'جرب البحث بكلمات أخرى أو إعادة ضبط الفلاتر الحالية.'
                : 'ستظهر طلبات عملائك هنا فور استلامها في المتجر.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 13,
              color: ColorResources.getTextSubTitle(context),
            ),
          ),
          if (hasFilterOrSearch) ...[
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  _searchQuery = '';
                });
                orderController.resetFilters();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AllineColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'إعادة ضبط الفلاتر والبحث',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AllineColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shimmer Loading Skeleton Matching Real Order Card
// -----------------------------------------------------------------------------

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlight = isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);

    Widget box(double height, double width, {double radius = 10}) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  box(16, 120),
                  box(20, 70, radius: 20),
                ],
              ),
              const SizedBox(height: 14),
              box(14, 180),
              const SizedBox(height: 6),
              box(12, 100),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  box(18, 90),
                  box(30, 80, radius: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
