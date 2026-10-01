import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/profile_info.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/domain/models/transaction_model.dart';
import 'package:sixvalley_vendor_app/features/transaction/screens/transaction_screen.dart';
import 'package:sixvalley_vendor_app/features/transaction/widgets/transaction_details_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/withdraw_balance_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class WalletScreen extends StatefulWidget {
  final bool fromNotification;
  const WalletScreen({super.key, this.fromNotification = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = true;
  bool _requestInProgress = false;
  bool _profileFailed = false;
  bool _transactionsFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted || _requestInProgress) return;
    _requestInProgress = true;
    setState(() => _isLoading = true);

    final profileController = context.read<ProfileController>();
    final transactionController = context.read<TransactionController>();
    final walletController = context.read<WalletController>();
    final results = await Future.wait<bool>([
      _loadProfile(profileController),
      _loadTransactions(transactionController),
      _loadWithdrawMethods(walletController),
      _loadSavedMethods(walletController),
    ]);

    if (!mounted) return;
    setState(() {
      _profileFailed = !results[0];
      _transactionsFailed = !results[1];
      _isLoading = false;
    });
    _requestInProgress = false;
  }

  Future<bool> _loadProfile(ProfileController controller) async {
    try {
      return (await controller.getSellerInfo()).isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadTransactions(TransactionController controller) async {
    try {
      await controller.getTransactionList(context, 'all', '', '');
      return controller.transactionList != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadWithdrawMethods(WalletController controller) async {
    try {
      await controller.getWithdrawMethods(context);
      return !controller.withdrawMethodLoadFailed;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadSavedMethods(WalletController controller) async {
    try {
      await controller.getPaymentInfoList();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _handleBack() {
    if (widget.fromNotification) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = ColorResources.getScaffoldBg(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: CustomAppBarWidget(
          title: 'المحفظة',
          onBackPressed: _handleBack,
        ),
        body: RefreshIndicator(
          color: AllineColors.primary,
          onRefresh: _loadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(
              16,
              8,
              16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Text(
                'تابع أموالك وطلبات السحب بوضوح',
                style: TextStyle(
                  color: ColorResources.getTextSubTitle(context),
                  fontSize: 14,
                  fontFamily: 'AllineTajawal',
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const _WalletLoadingState()
              else ...[
                if (_profileFailed ||
                    context.read<ProfileController>().userInfoModel == null)
                  _WalletErrorState(onRetry: _loadData)
                else ...[
                  const WithdrawBalanceWidget(),
                  const SizedBox(height: 14),
                  _BalanceStatusCards(
                    wallet: context
                        .watch<ProfileController>()
                        .userInfoModel
                        ?.wallet,
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(
                    title: 'ملخص مالي',
                    subtitle: 'الأرصدة المسجلة في حساب متجرك',
                  ),
                  const SizedBox(height: 10),
                  _FinancialSummaryCard(
                    wallet: context
                        .watch<ProfileController>()
                        .userInfoModel
                        ?.wallet,
                  ),
                ],
                const SizedBox(height: 22),
                _WithdrawalHistorySection(
                  failed: _transactionsFailed,
                  onRetry: _loadData,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceStatusCards extends StatelessWidget {
  const _BalanceStatusCards({required this.wallet});
  final Wallet? wallet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceStatusCard(
            title: 'طلبات معلقة',
            amount: wallet?.pendingWithdraw ?? 0,
            icon: Icons.hourglass_top_rounded,
            accent: AllineColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceStatusCard(
            title: 'إجمالي المسحوبات',
            amount: wallet?.withdrawn ?? 0,
            icon: Icons.check_circle_outline_rounded,
            accent: AllineColors.success,
          ),
        ),
      ],
    );
  }
}

class _BalanceStatusCard extends StatelessWidget {
  const _BalanceStatusCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.accent,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _WalletCard(
      padding: const EdgeInsetsDirectional.fromSTEB(13, 14, 13, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorResources.getTextSubTitle(context),
                    fontSize: 12,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              PriceConverter.convertPrice(context, amount),
              style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: 'AllineTajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({required this.wallet});
  final Wallet? wallet;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, double, IconData)>[
      (
        'عمولات المنصة المسجلة',
        wallet?.commissionGiven ?? 0,
        Icons.percent_rounded,
      ),
      (
        'رسوم التوصيل المحصلة',
        wallet?.deliveryChargeEarned ?? 0,
        Icons.local_shipping_outlined,
      ),
      (
        'النقد المحصل',
        wallet?.collectedCash ?? 0,
        Icons.payments_outlined,
      ),
      (
        'الضرائب المحصلة',
        wallet?.totalTaxCollected ?? 0,
        Icons.receipt_long_outlined,
      ),
    ];

    return _WalletCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 14, 13),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AllineColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(rows[index].$3,
                        color: AllineColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rows[index].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorResources.getTextSubTitle(context),
                        fontSize: 13,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        PriceConverter.convertPrice(context, rows[index].$2),
                        style: TextStyle(
                          color: ColorResources.getTextTitle(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AllineTajawal',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                indent: 58,
                color: ColorResources.getBorder(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _WithdrawalHistorySection extends StatelessWidget {
  const _WithdrawalHistorySection({
    required this.failed,
    required this.onRetry,
  });

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionController>().transactionList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionTitle(
                title: 'طلبات السحب',
                subtitle: 'حالة ومبالغ طلبات السحب من متجرك',
              ),
            ),
            if (!failed && (transactions?.isNotEmpty ?? false))
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionScreen(),
                  ),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                label: const Text('عرض الكل'),
                style: TextButton.styleFrom(
                  foregroundColor: AllineColors.primary,
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  textStyle: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (failed)
          _InlineRetry(onRetry: onRetry)
        else if (transactions == null)
          const _TransactionListSkeleton()
        else if (transactions.isEmpty)
          const _EmptyWithdrawalState()
        else
          _WalletCard(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
            child: Column(
              children: [
                for (var index = 0;
                    index < transactions.length && index < 5;
                    index++) ...[
                  _WithdrawalRequestTile(item: transactions[index]),
                  if (index < transactions.length - 1 && index < 4)
                    Divider(height: 1, color: ColorResources.getBorder(context)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _WithdrawalRequestTile extends StatelessWidget {
  const _WithdrawalRequestTile({required this.item});
  final TransactionModel item;

  @override
  Widget build(BuildContext context) {
    final status = _WithdrawalStatus.fromValue(item.approved);
    final date = _formatTransactionDate(item.createdAt);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TransactionDetailsWidget(transactionModel: item),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AllineColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.south_west_rounded,
                    color: AllineColors.primary, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب سحب #${item.id ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorResources.getTextTitle(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorResources.getTextSubTitle(context),
                              fontSize: 11,
                              fontFamily: 'AllineTajawal',
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        _StatusBadge(status: status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    PriceConverter.convertPrice(context, item.amount ?? 0),
                    style: TextStyle(
                      color: ColorResources.getTextTitle(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WithdrawalStatus {
  const _WithdrawalStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;

  static _WithdrawalStatus fromValue(int? approved) {
    switch (approved) {
      case 1:
        return const _WithdrawalStatus(
          'تمت الموافقة',
          AllineColors.success,
          Icons.check_circle_outline_rounded,
        );
      case 2:
        return const _WithdrawalStatus(
          'مرفوض',
          AllineColors.error,
          Icons.cancel_outlined,
        );
      default:
        return const _WithdrawalStatus(
          'قيد المراجعة',
          AllineColors.warning,
          Icons.schedule_rounded,
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final _WithdrawalStatus status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 3, 6, 3),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, color: status.color, size: 12),
            const SizedBox(width: 3),
            Text(
              status.label,
              maxLines: 1,
              style: TextStyle(
                color: status.color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'AllineTajawal',
              ),
            ),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});
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
            const SizedBox(height: 3),
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

class _WalletCard extends StatelessWidget {
  const _WalletCard({
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
          color: ColorResources.getCardBg(context),
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

class _WalletLoadingState extends StatelessWidget {
  const _WalletLoadingState();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _Skeleton(
            height: 188,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Skeleton(
                  height: 90,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Skeleton(
                  height: 90,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Skeleton(
            height: 218,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 22),
          _Skeleton(
            height: 250,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ],
      );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
      );
}

class _WalletErrorState extends StatelessWidget {
  const _WalletErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _WalletCard(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AllineColors.error, size: 34),
            const SizedBox(height: 10),
            Text(
              'تعذر تحميل بيانات المحفظة',
              style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'AllineTajawal',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'حاول تحديث الصفحة مرة أخرى.',
              style: TextStyle(
                color: ColorResources.getTextSubTitle(context),
                fontSize: 12,
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

class _EmptyWithdrawalState extends StatelessWidget {
  const _EmptyWithdrawalState();

  @override
  Widget build(BuildContext context) => _WalletCard(
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AllineColors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AllineColors.primary),
            ),
            const SizedBox(height: 9),
            Text(
              'لا توجد طلبات سحب بعد',
              style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'AllineTajawal',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'ستظهر طلبات السحب وحالاتها هنا.',
              style: TextStyle(
                color: ColorResources.getTextSubTitle(context),
                fontSize: 12,
                fontFamily: 'AllineTajawal',
              ),
            ),
          ],
        ),
      );
}

class _TransactionListSkeleton extends StatelessWidget {
  const _TransactionListSkeleton();

  @override
  Widget build(BuildContext context) => _WalletCard(
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
              child: _Skeleton(
                height: 52,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      );
}

class _InlineRetry extends StatelessWidget {
  const _InlineRetry({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _WalletCard(
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AllineColors.error, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'تعذر تحميل طلبات السحب.',
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

String _formatTransactionDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  try {
    return DateConverter.isoStringToDateTimeString(value);
  } catch (_) {
    final date = DateTime.tryParse(value);
    return date == null ? '—' : DateConverter.localDateToIsoStringAMPMOrder(date);
  }
}
