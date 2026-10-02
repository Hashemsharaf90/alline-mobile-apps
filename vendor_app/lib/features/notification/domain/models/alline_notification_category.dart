import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/notification_model.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

enum AllineNotificationCategory {
  all,
  orders,
  products,
  payments,
  store,
  system;

  String get id {
    switch (this) {
      case AllineNotificationCategory.all:
        return 'all';
      case AllineNotificationCategory.orders:
        return 'orders';
      case AllineNotificationCategory.products:
        return 'products';
      case AllineNotificationCategory.payments:
        return 'payments';
      case AllineNotificationCategory.store:
        return 'store';
      case AllineNotificationCategory.system:
        return 'system';
    }
  }

  String get label {
    switch (this) {
      case AllineNotificationCategory.all:
        return 'الكل';
      case AllineNotificationCategory.orders:
        return 'الطلبات';
      case AllineNotificationCategory.products:
        return 'المنتجات';
      case AllineNotificationCategory.payments:
        return 'المدفوعات';
      case AllineNotificationCategory.store:
        return 'المتجر';
      case AllineNotificationCategory.system:
        return 'النظام';
    }
  }

  IconData get icon {
    switch (this) {
      case AllineNotificationCategory.all:
        return Icons.auto_awesome_rounded;
      case AllineNotificationCategory.orders:
        return Icons.shopping_bag_outlined;
      case AllineNotificationCategory.products:
        return Icons.inventory_2_outlined;
      case AllineNotificationCategory.payments:
        return Icons.account_balance_wallet_outlined;
      case AllineNotificationCategory.store:
        return Icons.storefront_outlined;
      case AllineNotificationCategory.system:
        return Icons.notifications_active_outlined;
    }
  }

  Color get color {
    switch (this) {
      case AllineNotificationCategory.all:
        return AllineColors.primary;
      case AllineNotificationCategory.orders:
        return AllineColors.primary;
      case AllineNotificationCategory.products:
        return AllineColors.orange;
      case AllineNotificationCategory.payments:
        return AllineColors.success;
      case AllineNotificationCategory.store:
        return AllineColors.darkBlue;
      case AllineNotificationCategory.system:
        return AllineColors.coolGray;
    }
  }

  static AllineNotificationCategory fromId(String id) {
    switch (id) {
      case 'orders':
        return AllineNotificationCategory.orders;
      case 'products':
        return AllineNotificationCategory.products;
      case 'payments':
        return AllineNotificationCategory.payments;
      case 'store':
        return AllineNotificationCategory.store;
      case 'system':
        return AllineNotificationCategory.system;
      case 'all':
      default:
        return AllineNotificationCategory.all;
    }
  }

  /// Automatically detect the category of a notification based on its title and body.
  static AllineNotificationCategory detect(NotificationItem item) {
    final text = '${item.title ?? ''} ${item.description ?? ''}'.toLowerCase();

    // 1. Orders
    if (text.contains('طلب') ||
        text.contains('order') ||
        text.contains('شحن') ||
        text.contains('شحنة') ||
        text.contains('delivery') ||
        text.contains('توصيل') ||
        text.contains('مندوب') ||
        text.contains('استرداد') ||
        text.contains('refund')) {
      return AllineNotificationCategory.orders;
    }

    // 2. Products / Stock
    if (text.contains('منتج') ||
        text.contains('product') ||
        text.contains('مخزون') ||
        text.contains('stock') ||
        text.contains('كمية') ||
        text.contains('نفاد') ||
        text.contains('restock')) {
      return AllineNotificationCategory.products;
    }

    // 3. Finance & Payments
    if (text.contains('دفع') ||
        text.contains('رصيد') ||
        text.contains('سحب') ||
        text.contains('تحويل') ||
        text.contains('محفظة') ||
        text.contains('مالي') ||
        text.contains('payment') ||
        text.contains('wallet') ||
        text.contains('withdraw') ||
        text.contains('balance') ||
        text.contains('كاش') ||
        text.contains('حساب بنكي') ||
        text.contains('عمولة')) {
      return AllineNotificationCategory.payments;
    }

    // 4. Store & Account
    if (text.contains('متجر') ||
        text.contains('store') ||
        text.contains('shop') ||
        text.contains('إجازة') ||
        text.contains('vacation') ||
        text.contains('إغلاق') ||
        text.contains('شعار') ||
        text.contains('بانر') ||
        text.contains('وثائق') ||
        text.contains('ترقية') ||
        text.contains('onboarding')) {
      return AllineNotificationCategory.store;
    }

    // 5. System Default
    return AllineNotificationCategory.system;
  }

  /// Extract an order ID if present in title or description.
  static int? extractOrderId(NotificationItem item) {
    final fullText = '${item.title ?? ''} ${item.description ?? ''}';

    // Matches #10248 or # 10248
    final hashRegex = RegExp(r'#\s*(\d{3,8})');
    final hashMatch = hashRegex.firstMatch(fullText);
    if (hashMatch != null) {
      return int.tryParse(hashMatch.group(1) ?? '');
    }

    // Matches 'طلب 10248' or 'order 10248'
    final orderWordRegex = RegExp(r'(?:طلب|order)\s*:?\s*(\d{3,8})', caseSensitive: false);
    final orderMatch = orderWordRegex.firstMatch(fullText);
    if (orderMatch != null) {
      return int.tryParse(orderMatch.group(1) ?? '');
    }

    // Standalone 5+ digits
    final standaloneRegex = RegExp(r'\b(\d{4,8})\b');
    final standaloneMatch = standaloneRegex.firstMatch(fullText);
    if (standaloneMatch != null) {
      return int.tryParse(standaloneMatch.group(1) ?? '');
    }

    return null;
  }

  /// Format timestamp into warm, clean Arabic relative time.
  static String formatRelativeTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';

    try {
      DateTime dateTime;
      if (rawDate.contains('T')) {
        dateTime = DateTime.parse(rawDate).toLocal();
      } else {
        dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(rawDate).toLocal();
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'الآن';
      } else if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        if (m == 1) return 'منذ دقيقة';
        if (m == 2) return 'منذ دقيقتين';
        if (m >= 3 && m <= 10) return 'منذ $m دقائق';
        return 'منذ $m دقيقة';
      } else if (difference.inHours < 24) {
        final h = difference.inHours;
        if (h == 1) return 'منذ ساعة';
        if (h == 2) return 'منذ ساعتين';
        if (h >= 3 && h <= 10) return 'منذ $h ساعات';
        return 'منذ $h ساعة';
      } else if (difference.inDays == 1) {
        final timeStr = DateFormat('hh:mm a').format(dateTime)
            .replaceAll('AM', 'ص')
            .replaceAll('PM', 'م');
        return 'أمس في $timeStr';
      } else if (difference.inDays < 7) {
        final d = difference.inDays;
        if (d == 2) return 'منذ يومين';
        return 'منذ $d أيام';
      } else {
        return DateFormat('yyyy/MM/dd').format(dateTime);
      }
    } catch (_) {
      return rawDate;
    }
  }
}
