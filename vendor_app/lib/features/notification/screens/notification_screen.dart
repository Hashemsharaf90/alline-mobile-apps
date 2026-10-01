import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_card_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_categories_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_empty_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_error_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_header_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_settings_sheet.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_skeleton_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_summary_widget.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    context.read<NotificationController>().getNotificationList(1, reload: false);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final controller = context.read<NotificationController>();

    if (currentScroll >= (maxScroll - 150) &&
        !controller.isPaginating &&
        !controller.isLoading) {
      final model = controller.notificationModel;
      if (model != null &&
          model.offset != null &&
          model.totalSize != null &&
          (model.notification?.length ?? 0) < model.totalSize!) {
        controller.getNotificationList(model.offset! + 1);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<NotificationController>().getNotificationList(1, reload: true);
  }

  void _openSettingsSheet() {
    AllineNotificationSettingsSheet.show(context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AllineColors.darkScaffold
            : AllineColors.softBlue,
        body: Column(
          children: [
            // 1. Header (الإشعارات + تحديد الكل كمقروء + إعدادات)
            AllineNotificationHeaderWidget(
              onOpenSettings: _openSettingsSheet,
            ),

            // 2. Notification Summary & Filter (X إشعاراً جديداً | الكل | غير مقروء)
            const AllineNotificationSummaryWidget(),

            // 3. Category Horizontal Pills (الكل، الطلبات، المنتجات، المدفوعات، المتجر، النظام)
            const AllineNotificationCategoriesWidget(),

            const SizedBox(height: 6),

            // 4. Notifications Body (List / Empty / Skeleton / Error)
            Expanded(
              child: Consumer<NotificationController>(
                builder: (context, controller, _) {
                  // A. Initial Loading State
                  if (controller.isLoading &&
                      controller.notificationModel == null) {
                    return const SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: AllineNotificationSkeletonWidget(),
                    );
                  }

                  // B. Initial Error State
                  if (controller.hasError &&
                      controller.notificationModel == null) {
                    return AllineNotificationErrorWidget(
                      onRetry: () => controller.getNotificationList(1, reload: true),
                    );
                  }

                  final list = controller.filteredNotifications;

                  // C. Empty State
                  if (list.isEmpty) {
                    return RefreshIndicator(
                      color: AllineColors.primary,
                      backgroundColor: isDark ? AllineColors.darkCard : AllineColors.white,
                      onRefresh: _handleRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: const AllineNotificationEmptyWidget(),
                          ),
                        ],
                      ),
                    );
                  }

                  // D. Populated Notification List
                  return RefreshIndicator(
                    color: AllineColors.primary,
                    backgroundColor: isDark ? AllineColors.darkCard : AllineColors.white,
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(top: 2, bottom: 24),
                      itemCount: list.length + (controller.isPaginating ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == list.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AllineColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final item = list[index];
                        return AllineNotificationCardWidget(
                          notificationItem: item,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}