import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/alline_notification_category.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/notification_model.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/alline_notification_details_sheet.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/shop_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationCardWidget extends StatelessWidget {
  final NotificationItem notificationItem;

  const AllineNotificationCardWidget({
    super.key,
    required this.notificationItem,
  });

  void _handleTap(BuildContext context) {
    final controller = context.read<NotificationController>();
    if (notificationItem.id != null) {
      controller.seenNotification(notificationItem.id!);
    }

    final category = AllineNotificationCategory.detect(notificationItem);
    final orderId = AllineNotificationCategory.extractOrderId(notificationItem);

    VoidCallback? onNavigate;
    String? actionLabel;

    if (category == AllineNotificationCategory.orders && orderId != null) {
      actionLabel = 'عرض تفاصيل الطلب #$orderId';
      onNavigate = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(
              orderId: orderId,
              fromNotification: true,
            ),
          ),
        );
      };
    } else if (category == AllineNotificationCategory.products) {
      actionLabel = 'إدارة قائمة المنتجات';
      onNavigate = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductListMenuScreen(fromNotification: true),
          ),
        );
      };
    } else if (category == AllineNotificationCategory.payments) {
      actionLabel = 'الانتقال للمحفظة والمالية';
      onNavigate = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WalletScreen(fromNotification: true),
          ),
        );
      };
    } else if (category == AllineNotificationCategory.store) {
      actionLabel = 'فتح إدارة المتجر';
      onNavigate = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ShopScreen(),
          ),
        );
      };
    }

    // If direct navigation exists for specific order, go directly
    if (category == AllineNotificationCategory.orders && orderId != null && onNavigate != null) {
      onNavigate();
    } else {
      // Show details sheet with deep link button
      AllineNotificationDetailsSheet.show(
        context,
        item: notificationItem,
        actionLabel: actionLabel,
        onNavigate: onNavigate,
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AllineColors.darkCard : AllineColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'حذف الإشعار',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AllineColors.darkText : AllineColors.navyText,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا الإشعار من قائمتك؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 13,
            color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (notificationItem.id != null) {
                context
                    .read<NotificationController>()
                    .removeNotificationLocally(notificationItem.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllineColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = (notificationItem.notificationSeenStatus ?? 0) == 0;
    final category = AllineNotificationCategory.detect(notificationItem);
    final relativeTime =
        AllineNotificationCategory.formatRelativeTime(notificationItem.createdAt);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Slidable(
          key: ValueKey(notificationItem.id ?? UniqueKey()),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) {
                  if (notificationItem.id != null) {
                    context
                        .read<NotificationController>()
                        .seenNotification(notificationItem.id!);
                  }
                },
                backgroundColor: AllineColors.primary.withValues(alpha: 0.12),
                foregroundColor: AllineColors.primary,
                icon: Icons.done_all_rounded,
                label: 'قراءة',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => _showDeleteConfirmation(context),
                backgroundColor: AllineColors.error.withValues(alpha: 0.12),
                foregroundColor: AllineColors.error,
                icon: Icons.delete_outline_rounded,
                label: 'حذف',
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(context),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isUnread
                      ? (isDark
                          ? const Color(0xFF1B273F)
                          : const Color(0xFFF3F8FF))
                      : (isDark
                          ? AllineColors.darkCard
                          : AllineColors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnread
                        ? (isDark
                            ? AllineColors.primary.withValues(alpha: 0.4)
                            : AllineColors.primary.withValues(alpha: 0.3))
                        : (isDark
                            ? AllineColors.darkBorder
                            : AllineColors.border),
                    width: isUnread ? 1.2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content: Title, Description, Timestamp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notificationItem.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 14,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isDark
                                        ? AllineColors.darkText
                                        : AllineColors.navyText,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AllineColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Description
                          if (notificationItem.description != null &&
                              notificationItem.description!.isNotEmpty)
                            Text(
                              notificationItem.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? AllineColors.darkTextSub
                                    : (isUnread
                                        ? const Color(0xFF4A5F80)
                                        : AllineColors.coolGray),
                                height: 1.4,
                              ),
                            ),
                          const SizedBox(height: 6),

                          // Relative Time & Category Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: isDark
                                        ? AllineColors.darkTextSub
                                        : AllineColors.coolGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    relativeTime,
                                    style: TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AllineColors.darkTextSub
                                          : AllineColors.coolGray,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  category.label,
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: category.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
