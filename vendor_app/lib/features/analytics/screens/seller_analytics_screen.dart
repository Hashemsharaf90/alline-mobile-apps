import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/chart_widget.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/business_analytics_filter_data.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/top_selling_product_model.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class SellerAnalyticsScreen extends StatefulWidget {
  final bool isBackButtonExist;
  const SellerAnalyticsScreen({super.key, this.isBackButtonExist = false});

  @override
  State<SellerAnalyticsScreen> createState() => _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends State<SellerAnalyticsScreen> {
  static const List<String> _periodTitles = [
    'اليوم',
    'هذا الأسبوع',
    'هذا الشهر',
    'هذا العام',
  ];
  static const List<String> _periodKeys = [
    'today',
    'this_week',
    'this_month',
    'this_year',
  ];
  static const List<String> _revenueKeys = [
    'todayEarn',
    'WeekEarn',
    'MonthEarn',
    'yearEarn',
  ];

  int _selectedPeriodIndex = 0;
  bool _periodLoading = true;
  bool _topProductsLoading = true;
  bool _topProductsFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchData(loadTopProducts: true);
    });
  }

  Future<void> _fetchData({bool loadTopProducts = false}) async {
    if (!mounted) return;
    setState(() {
      _periodLoading = true;
      if (loadTopProducts) {
        _topProductsLoading = true;
        _topProductsFailed = false;
      }
    });

    final bankController =
        Provider.of<BankInfoController>(context, listen: false);
    final productController =
        Provider.of<ProductController>(context, listen: false);
    final requests = <Future<void>>[
      bankController.getAnalyticsFilterData(
        context,
        _periodKeys[_selectedPeriodIndex],
      ),
      bankController.getDashboardRevenueData(
        context,
        _revenueKeys[_selectedPeriodIndex],
      ),
    ];
    if (loadTopProducts) {
      requests.add(productController.getTopSellingProductList(
        1,
        context,
        'en',
        reload: true,
      ));
    }

    try {
      await Future.wait(requests);
    } catch (_) {
      // Each section keeps its own response/error state and remains usable.
    } finally {
      if (mounted) {
        setState(() {
          _periodLoading = false;
          if (loadTopProducts) {
            _topProductsLoading = false;
            _topProductsFailed = productController.topSellingProductModel == null;
          }
        });
      }
    }
  }

  Future<void> _reloadTopProducts() async {
    if (!mounted) return;
    setState(() {
      _topProductsLoading = true;
      _topProductsFailed = false;
    });
    final controller = Provider.of<ProductController>(context, listen: false);
    try {
      await controller.getTopSellingProductList(1, context, 'en', reload: true);
    } catch (_) {
      // Keep the error local to the product ranking section.
    } finally {
      if (mounted) {
        setState(() {
          _topProductsLoading = false;
          _topProductsFailed = controller.topSellingProductModel == null;
        });
      }
    }
  }

  Future<void> _onPeriodChanged(int index) async {
    if (index == _selectedPeriodIndex || _periodLoading) return;
    setState(() => _selectedPeriodIndex = index);
    await _fetchData();
  }

  bool _hasOrderData(BankInfoController controller) {
    final data = controller.businessAnalyticsFilterData;
    if (data == null) return false;
    return [
      data.pending,
      data.confirmed,
      data.processing,
      data.outForDelivery,
      data.delivered,
      data.canceled,
      data.returned,
      data.failed,
    ].any((value) => value != null);
  }

  bool _hasAnyAnalyticsData(
    BankInfoController bankController,
    ProductController productController,
  ) {
    return _hasOrderData(bankController) ||
        bankController.hasSellerEarningsData ||
        bankController.hasCommissionData ||
        (productController.topSellingProductModel?.products?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      appBar: AppBar(
        backgroundColor: ColorResources.getCardBg(context),
        surfaceTintColor: ColorResources.getCardBg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: widget.isBackButtonExist,
        title: Text(
          'الإحصائيات',
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorResources.getTextTitle(context),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AllineColors.primary,
        onRefresh: () => _fetchData(loadTopProducts: true),
        child: Consumer2<BankInfoController, ProductController>(
          builder: (context, bankController, productController, _) {
            final noData = !_periodLoading &&
                !_hasAnyAnalyticsData(bankController, productController) &&
                !bankController.analyticsFilterFailed &&
                !bankController.revenueDataFailed &&
                !_topProductsFailed;
            final fullError = !_periodLoading &&
                bankController.analyticsFilterFailed &&
                bankController.revenueDataFailed &&
                _topProductsFailed;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'افهم أداء متجرك واتخذ قرارات أفضل',
                    style: TextStyle(
                      color: ColorResources.getTextSubTitle(context),
                      fontSize: 14,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PeriodSelector(
                    selectedIndex: _selectedPeriodIndex,
                    isLoading: _periodLoading,
                    onSelected: _onPeriodChanged,
                  ),
                  const SizedBox(height: 16),
                  if (fullError)
                    _FullError(onRetry: () => _fetchData(loadTopProducts: true))
                  else if (noData)
                    const _EmptyAnalyticsState()
                  else ...[
                    if (_periodLoading)
                      const _AnalyticsSkeleton()
                    else ...[
                      if (bankController.revenueDataFailed)
                        _SectionError(
                          title: 'تعذر تحميل بيانات الأرباح',
                          onRetry: () => _fetchData(),
                        )
                      else
                        _RevenueCard(
                          loading: _periodLoading,
                          hasData: bankController.hasSellerEarningsData,
                          values: bankController.userEarnings,
                          selectedPeriod: _periodTitles[_selectedPeriodIndex],
                        ),
                      const SizedBox(height: 14),
                      if (bankController.analyticsFilterFailed)
                        _SectionError(
                          title: 'تعذر تحميل أداء الطلبات',
                          onRetry: () => _fetchData(),
                        )
                      else if (bankController.businessAnalyticsFilterData != null)
                        _OrderMetrics(
                          data: bankController.businessAnalyticsFilterData!,
                        ),
                      if (!bankController.revenueDataFailed &&
                          bankController.userEarnings != null &&
                          bankController.userCommissions != null) ...[
                        const SizedBox(height: 22),
                        const _SectionHeading(
                          title: 'اتجاه أرباح البائع والعمولة',
                          subtitle: 'القيم خلال الفترة المحددة',
                        ),
                        const SizedBox(height: 10),
                        _AnalyticsCard(
                          child: ChartWidget(showPeriodSelector: false),
                        ),
                      ],
                    ],
                  ],
                  const SizedBox(height: 22),
                  _TopProductsSection(
                    products: productController.topSellingProductModel?.products,
                    isLoading: _topProductsLoading,
                    hasError: _topProductsFailed,
                    onRetry: _reloadTopProducts,
                  ),
                  if (bankController.businessAnalyticsFilterData != null &&
                      !bankController.analyticsFilterFailed) ...[
                    const SizedBox(height: 20),
                    _OrderPerformanceSection(
                      data: bankController.businessAnalyticsFilterData!,
                    ),
                  ],
                  if (bankController.revenueDataFailed ||
                      bankController.analyticsFilterFailed) ...[
                    const SizedBox(height: 12),
                    Text(
                      'نعرض الأقسام التي أمكن تحميل بياناتها فقط.',
                      style: TextStyle(
                        color: ColorResources.getTextSubTitle(context),
                        fontSize: 12,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedIndex,
    required this.isLoading,
    required this.onSelected,
  });

  final int selectedIndex;
  final bool isLoading;
  final ValueChanged<int> onSelected;

  static const List<String> labels = [
    'اليوم',
    'هذا الأسبوع',
    'هذا الشهر',
    'هذا العام',
  ];

  @override
  Widget build(BuildContext context) {
    final border = ColorResources.getBorder(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = selectedIndex == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? AllineColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: isLoading ? null : () => onSelected(index),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          labels[index],
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : ColorResources.getTextSubTitle(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.loading,
    required this.hasData,
    required this.values,
    required this.selectedPeriod,
  });

  final bool loading;
  final bool hasData;
  final List<double?>? values;
  final String selectedPeriod;

  @override
  Widget build(BuildContext context) {
    final points = values?.skip(1).whereType<double>().toList() ?? <double>[];
    final amount = points.fold<double>(0, (sum, value) => sum + value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AllineColors.primary, AllineColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primary.withValues(alpha: .16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'أرباح البائع المسجّلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ),
              Text(
                selectedPeriod,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .8),
                  fontSize: 11,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            const _LightSkeleton(width: 190, height: 30)
          else if (hasData)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                PriceConverter.convertPrice(context, amount),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            )
          else
            Text(
              'لا توجد أرباح مسجّلة لهذه الفترة',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .9),
                fontSize: 14,
                fontFamily: 'AllineTajawal',
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'بيانات أرباح البائع من النظام، وليست إجمالي المبيعات أو صافي الربح.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              fontSize: 11,
              height: 1.4,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMetrics extends StatelessWidget {
  const _OrderMetrics({required this.data});

  final BusinessAnalyticsFilterDataModel data;

  int? get _total {
    final values = <int?>[
      data.pending,
      data.confirmed,
      data.processing,
      data.outForDelivery,
      data.delivered,
      data.canceled,
      data.returned,
      data.failed,
    ];
    if (values.any((value) => value == null)) return null;
    return values.whereType<int>().fold<int>(0, (sum, value) => sum + value);
  }

  int? get _inProgress {
    final values = <int?>[
      data.pending,
      data.confirmed,
      data.processing,
      data.outForDelivery,
    ];
    if (values.any((value) => value == null)) return null;
    return values.whereType<int>().fold<int>(0, (sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final values = [
      _MetricValue('الطلبات', _total, Icons.receipt_long_outlined,
          AllineColors.primary),
      _MetricValue('المكتملة', data.delivered, Icons.check_circle_outline,
          AllineColors.success),
      _MetricValue('قيد التنفيذ', _inProgress, Icons.pending_outlined,
          AllineColors.warning),
      _MetricValue('الإلغاءات', data.canceled, Icons.cancel_outlined,
          AllineColors.error),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(value: values[0])),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(value: values[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _MetricCard(value: values[2])),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(value: values[3])),
          ],
        ),
      ],
    );
  }
}

class _MetricValue {
  const _MetricValue(this.label, this.value, this.icon, this.color);
  final String label;
  final int? value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value});
  final _MetricValue value;

  @override
  Widget build(BuildContext context) => _AnalyticsCard(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: value.color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(value.icon, color: value.color, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.value?.toString() ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorResources.getTextTitle(context),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorResources.getTextSubTitle(context),
                      fontSize: 11,
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

class _OrderPerformanceSection extends StatelessWidget {
  const _OrderPerformanceSection({required this.data});
  final BusinessAnalyticsFilterDataModel data;

  int? get _total {
    final values = <int?>[
      data.pending,
      data.confirmed,
      data.processing,
      data.outForDelivery,
      data.delivered,
      data.canceled,
      data.returned,
      data.failed,
    ];
    if (values.any((value) => value == null)) return null;
    return values.whereType<int>().fold<int>(0, (sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final rows = <(String, int?, Color)>[
      ('مكتملة', data.delivered, AllineColors.success),
      ('قيد التأكيد', data.pending, AllineColors.primary),
      ('مؤكدة', data.confirmed, AllineColors.brightBlue),
      ('قيد التجهيز', data.processing, AllineColors.warning),
      ('مع المندوب', data.outForDelivery, AllineColors.orange),
      ('ملغاة', data.canceled, AllineColors.error),
      ('مرتجعة', data.returned, ColorResources.getTextSubTitle(context)),
      ('فشل التسليم', data.failed, ColorResources.getTextSubTitle(context)),
    ];
    final availableRows = rows.where((row) => row.$2 != null).toList();
    if (availableRows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'أداء الطلبات',
          subtitle: 'توزيع الحالات للفترة المحددة',
        ),
        const SizedBox(height: 10),
        _AnalyticsCard(
          child: Column(
            children: [
              for (var index = 0; index < availableRows.length; index++) ...[
                _OrderStatusRow(
                  label: availableRows[index].$1,
                  count: availableRows[index].$2!,
                  total: total,
                  color: availableRows[index].$3,
                ),
                if (index != availableRows.length - 1)
                  const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderStatusRow extends StatelessWidget {
  const _OrderStatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int? total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasRatio = total != null && total! > 0;
    final ratio = hasRatio ? (count / total!).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ColorResources.getTextTitle(context),
                  fontSize: 12,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'AllineTajawal',
              ),
            ),
            if (hasRatio) ...[
              const SizedBox(width: 8),
              Text(
                '${(ratio * 100).round()}%',
                style: TextStyle(
                  color: ColorResources.getTextSubTitle(context),
                  fontSize: 11,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ],
          ],
        ),
        if (hasRatio) ...[
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: ColorResources.getBorder(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  const _TopProductsSection({
    required this.products,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final List<Products>? products;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'الأكثر مبيعًا',
          subtitle: 'ترتيب المنتجات بحسب بيانات المبيعات المتاحة',
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const _TopProductsSkeleton()
        else if (hasError)
          _SectionError(title: 'تعذر تحميل المنتجات الأكثر مبيعًا', onRetry: onRetry)
        else if (products == null || products!.isEmpty)
          const _AnalyticsCard(
            child: _InlineEmptyState(text: 'لا توجد بيانات مبيعات للمنتجات حتى الآن.'),
          )
        else
          _AnalyticsCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var index = 0; index < products!.length && index < 5; index++)
                  _TopProductRow(
                    rank: index + 1,
                    item: products![index],
                    isLast: index == products!.length - 1 || index == 4,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({
    required this.rank,
    required this.item,
    required this.isLast,
  });

  final int rank;
  final Products item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: AllineColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: 'AllineTajawal',
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: CustomImageWidget(
                image: product?.thumbnailFullUrl?.path ?? '',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name?.trim().isNotEmpty == true
                      ? product!.name!.trim()
                      : 'منتج',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorResources.getTextTitle(context),
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'عدد المبيعات: ${item.count ?? '—'}',
                  style: TextStyle(
                    color: ColorResources.getTextSubTitle(context),
                    fontSize: 11,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        if (product == null) child else InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productModel: product),
            ),
          ),
          child: child,
        ),
        if (!isLast) Divider(height: 1, color: ColorResources.getBorder(context)),
      ],
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const _LightSkeleton(width: double.infinity, height: 132, radius: 18),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _LightSkeleton(width: double.infinity, height: 78)),
              SizedBox(width: 10),
              Expanded(child: _LightSkeleton(width: double.infinity, height: 78)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _LightSkeleton(width: double.infinity, height: 78)),
              SizedBox(width: 10),
              Expanded(child: _LightSkeleton(width: double.infinity, height: 78)),
            ],
          ),
          const SizedBox(height: 18),
          const _LightSkeleton(width: double.infinity, height: 280, radius: 16),
          const SizedBox(height: 18),
          const _LightSkeleton(width: double.infinity, height: 220, radius: 16),
        ],
      );
}

class _TopProductsSkeleton extends StatelessWidget {
  const _TopProductsSkeleton();

  @override
  Widget build(BuildContext context) => _AnalyticsCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  _LightSkeleton(width: 44, height: 44, radius: 10),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LightSkeleton(width: double.infinity, height: 12, radius: 5),
                        SizedBox(height: 8),
                        _LightSkeleton(width: 100, height: 9, radius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _LightSkeleton extends StatelessWidget {
  const _LightSkeleton({
    required this.width,
    required this.height,
    this.radius = 10,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF26344A) : const Color(0xFFE5ECF5),
      highlightColor: isDark ? const Color(0xFF34445D) : Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ColorResources.getTextTitle(context),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'AllineTajawal',
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: ColorResources.getTextSubTitle(context),
                fontSize: 12,
                fontFamily: 'AllineTajawal',
              ),
            ),
          ],
        ],
      );
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorResources.getBorder(context)),
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: AllineColors.darkBlue.withValues(alpha: .025),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: child,
      );
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.title, required this.onRetry});
  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _AnalyticsCard(
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AllineColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: ColorResources.getTextTitle(context),
                  fontSize: 13,
                  fontFamily: 'AllineTajawal',
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
}

class _FullError extends StatelessWidget {
  const _FullError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _AnalyticsCard(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined,
                color: ColorResources.getTextSubTitle(context), size: 42),
            const SizedBox(height: 12),
            Text(
              'تعذر تحميل الإحصائيات',
              style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'AllineTajawal',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'حاول مرة أخرى.',
              style: TextStyle(
                color: ColorResources.getTextSubTitle(context),
                fontSize: 13,
                fontFamily: 'AllineTajawal',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
}

class _EmptyAnalyticsState extends StatelessWidget {
  const _EmptyAnalyticsState();

  @override
  Widget build(BuildContext context) => _AnalyticsCard(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AllineColors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded,
                  color: AllineColors.primary, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              'لا توجد بيانات كافية بعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'AllineTajawal',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ستظهر إحصائيات متجرك بعد بدء استقبال الطلبات.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorResources.getTextSubTitle(context),
                fontSize: 13,
                height: 1.45,
                fontFamily: 'AllineTajawal',
              ),
            ),
          ],
        ),
      );
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorResources.getTextSubTitle(context),
            fontSize: 13,
            fontFamily: 'AllineTajawal',
          ),
        ),
      );
}
