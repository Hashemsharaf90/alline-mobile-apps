import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/chart_widget.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/top_selling_product_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/most_popular_product_screen.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class SellerAnalyticsScreen extends StatefulWidget {
  final bool isBackButtonExist;
  const SellerAnalyticsScreen({super.key, this.isBackButtonExist = false});

  @override
  State<SellerAnalyticsScreen> createState() => _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends State<SellerAnalyticsScreen> {
  int _selectedPeriodIndex = 0; // 0: اليوم, 1: هذا الأسبوع, 2: هذا الشهر, 3: هذا العام
  final List<String> _periodTitles = ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذا العام'];
  final List<String> _periodKeys = ['today', 'this_week', 'this_month', 'this_year'];
  final List<String> _revenueKeys = ['todayEarn', 'WeekEarn', 'MonthEarn', 'yearEarn'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final bankCtrl = Provider.of<BankInfoController>(context, listen: false);
    bankCtrl.getAnalyticsFilterData(context, _periodKeys[_selectedPeriodIndex]);
    bankCtrl.getDashboardRevenueData(context, _revenueKeys[_selectedPeriodIndex]);
    final prodCtrl = Provider.of<ProductController>(context, listen: false);
    prodCtrl.getTopSellingProductList(1, context, 'en', reload: true);
    prodCtrl.getMostPopularProductList(1, context, 'en', reload: true);
  }

  void _onPeriodChanged(int index) {
    setState(() {
      _selectedPeriodIndex = index;
    });
    final bankCtrl = Provider.of<BankInfoController>(context, listen: false);
    bankCtrl.setAnalyticsFilterName(context, _periodKeys[index], true);
    bankCtrl.getDashboardRevenueData(context, _revenueKeys[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllineColors.softBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: widget.isBackButtonExist,
        title: const Text(
          'التحليلات والإحصائيات',
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AllineColors.navyText,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AllineColors.primary,
        onRefresh: () async => _fetchData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Period Selector Pills
              _buildPeriodSelector(),
              const SizedBox(height: 16),

              // 2. Main KPI Summary Cards
              Consumer<BankInfoController>(
                builder: (context, bankCtrl, _) {
                  final analytics = bankCtrl.businessAnalyticsFilterData;
                  final int pending = analytics?.pending ?? 0;
                  final int processing = analytics?.processing ?? 0;
                  final int delivered = analytics?.delivered ?? 0;
                  final int canceled = analytics?.canceled ?? 0;
                  final int totalOrders = pending + processing + delivered + canceled;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'إجمالي الطلبات',
                              value: '$totalOrders',
                              icon: Icons.receipt_long_rounded,
                              iconColor: AllineColors.primary,
                              iconBg: const Color(0xFFEBF3FC),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'المكتملة',
                              value: '$delivered',
                              icon: Icons.check_circle_rounded,
                              iconColor: AllineColors.success,
                              iconBg: const Color(0xFFE8F7EE),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'قيد التجهيز',
                              value: '$processing',
                              icon: Icons.hourglass_top_rounded,
                              iconColor: AllineColors.orange,
                              iconBg: const Color(0xFFFEF5E7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'الملغية',
                              value: '$canceled',
                              icon: Icons.cancel_rounded,
                              iconColor: AllineColors.error,
                              iconBg: const Color(0xFFFDEBEC),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Revenue Trend Chart Container
              const Text(
                'منحنى الأرباح والمبيعات',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AllineColors.navyText,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AllineColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AllineColors.darkBlue.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: const ChartWidget(),
              ),
              const SizedBox(height: 22),

              // 4. Best Sellers Section
              const Text(
                'المنتجات الأكثر مبيعاً',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AllineColors.navyText,
                ),
              ),
              const SizedBox(height: 10),
              const TopSellingProductScreen(isMain: true),
              const SizedBox(height: 20),

              // 5. Popular Products Section
              const Text(
                'المنتجات الأكثر رواجاً',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AllineColors.navyText,
                ),
              ),
              const SizedBox(height: 10),
              const MostPopularProductScreen(isMain: true),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllineColors.border),
      ),
      child: Row(
        children: List.generate(_periodTitles.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => _onPeriodChanged(index),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AllineColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  _periodTitles[index],
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AllineColors.coolGray,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AllineColors.border),
        boxShadow: [
          BoxShadow(
            color: AllineColors.darkBlue.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AllineColors.navyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12,
                    color: AllineColors.coolGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
