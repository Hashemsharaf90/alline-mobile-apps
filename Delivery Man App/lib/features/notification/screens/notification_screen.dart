import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_delivery_boy/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';
import 'package:sixvalley_delivery_boy/features/notification/widgets/notification_card_item_widget.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, required this.fromNotification});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scroll = ScrollController();
  int? _seen;
  @override
  void initState() {
    super.initState();
    final controller = Get.find<NotificationController>();
    _seen = controller.getSeenNotificationId();
    controller.getNotificationList(1);
    _scroll.addListener(_paginate);
  }

  void _paginate() {
    final controller = Get.find<NotificationController>();
    if (_scroll.position.extentAfter < 200 &&
        !controller.isLoading &&
        !controller.loadFailed &&
        (controller.notificationList?.length ?? 0) <
            (controller.notificationModel?.totalSize ?? 0)) {
      controller.getNotificationList(
          (int.tryParse(controller.notificationModel?.offset ?? '1') ?? 1) + 1,
          reload: false);
    }
  }

  void _markSeen() {
    final items = Get.find<NotificationController>().notificationList;
    if (items != null && items.isNotEmpty) {
      final ids = items.map((e) => e.id ?? 0);
      Get.find<NotificationController>()
          .saveSeenNotificationId(ids.reduce((a, b) => a > b ? a : b));
    }
  }

  void _back() {
    _markSeen();
    if (widget.fromNotification) {
      Get.offAll(() => const DashboardScreen(pageIndex: 0));
    } else {
      Get.back();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !widget.fromNotification,
      onPopInvokedWithResult: (didPop, _) {
        _markSeen();
        if (!didPop && widget.fromNotification) _back();
      },
      child: Scaffold(
          appBar: CustomAppBarWidget(
              title: 'notification'.tr, isBack: true, onTap: _back),
          body: GetBuilder<NotificationController>(builder: (controller) {
            final items = controller.notificationList ?? [];
            return RefreshIndicator(
                onRefresh: () => controller.getNotificationList(1),
                child: ListView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (controller.isLoading && items.isEmpty)
                        const AllineSkeleton(),
                      if (controller.loadFailed)
                        AllineErrorState(
                            onRetry: () => controller.getNotificationList(1)),
                      if (!controller.isLoading &&
                          !controller.loadFailed &&
                          items.isEmpty)
                        AllineEmptyState(
                            title: 'alline_no_notifications'.tr,
                            subtitle: '',
                            icon: Icons.notifications_none_rounded),
                      for (var i = 0; i < items.length; i++)
                        NotificationCardWidget(
                            notificationModel: items[i],
                            index: i,
                            isSeen: (items[i].id ?? 0) <= (_seen ?? 0)),
                      if (controller.isLoading && items.isNotEmpty)
                        const AllineSkeleton(count: 1),
                    ]));
          })));
}
