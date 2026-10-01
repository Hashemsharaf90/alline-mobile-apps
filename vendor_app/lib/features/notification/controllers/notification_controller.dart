import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/data/model/response/response_model.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/alline_notification_category.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/notification_model.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/services/notification_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

class NotificationController with ChangeNotifier {
  final NotificationServiceInterface notificationServiceInterface;

  NotificationController({required this.notificationServiceInterface});

  NotificationItemModel? notificationModel;

  bool _isLoading = false;
  bool _isPaginating = false;
  bool _hasError = false;
  String? _errorMessage;

  // 0: All, 1: Unread
  int _unreadFilterIndex = 0;

  // 'all', 'orders', 'products', 'payments', 'store', 'system'
  String _selectedCategory = 'all';

  bool get isLoading => _isLoading;
  bool get isPaginating => _isPaginating;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get unreadFilterIndex => _unreadFilterIndex;
  String get selectedCategory => _selectedCategory;

  /// Total count of unread notifications
  int get unreadCount {
    if (notificationModel?.notification == null) {
      return notificationModel?.newNotificationItem ?? 0;
    }
    return notificationModel!.notification!
        .where((item) => (item.notificationSeenStatus ?? 0) == 0)
        .length;
  }

  /// Change filter between All (0) and Unread (1)
  void setUnreadFilter(int index) {
    if (_unreadFilterIndex != index) {
      _unreadFilterIndex = index;
      notifyListeners();
    }
  }

  /// Change active category filter
  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Get the list of notifications filtered by category & read status
  List<NotificationItem> get filteredNotifications {
    final all = notificationModel?.notification ?? [];
    if (all.isEmpty) return [];

    return all.where((item) {
      // 1. Read / Unread filter
      if (_unreadFilterIndex == 1) {
        final isUnread = (item.notificationSeenStatus ?? 0) == 0;
        if (!isUnread) return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'all') {
        final detected = AllineNotificationCategory.detect(item);
        if (detected.id != _selectedCategory) return false;
      }

      return true;
    }).toList();
  }

  /// Counts of items per category
  Map<String, int> get categoryCounts {
    final map = <String, int>{
      'all': 0,
      'orders': 0,
      'products': 0,
      'payments': 0,
      'store': 0,
      'system': 0,
    };

    final list = notificationModel?.notification ?? [];
    map['all'] = list.length;

    for (final item in list) {
      final cat = AllineNotificationCategory.detect(item);
      map[cat.id] = (map[cat.id] ?? 0) + 1;
    }

    return map;
  }

  /// Fetch notifications list with pagination support
  Future<void> getNotificationList(int offset, {bool reload = false}) async {
    if (offset == 1) {
      if (reload || notificationModel == null) {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
        notifyListeners();
      }
    } else {
      _isPaginating = true;
      notifyListeners();
    }

    try {
      ApiResponse apiResponse =
          await notificationServiceInterface.getNotificationList(offset);

      if (apiResponse.response?.statusCode == 200 &&
          apiResponse.response?.data != null) {
        final newModel =
            NotificationItemModel.fromJson(apiResponse.response?.data);

        if (offset == 1) {
          notificationModel = newModel;
        } else {
          if (newModel.notification != null &&
              newModel.notification!.isNotEmpty) {
            notificationModel?.notification?.addAll(newModel.notification!);
          }
          notificationModel?.offset = newModel.offset;
          notificationModel?.totalSize = newModel.totalSize;
        }
        _hasError = false;
        _errorMessage = null;
      } else {
        _hasError = offset == 1 && notificationModel == null;
        _errorMessage = 'تعذر تحميل الإشعارات';
        ApiChecker.checkApi(apiResponse);
      }
    } catch (e) {
      if (offset == 1 && notificationModel == null) {
        _hasError = true;
        _errorMessage = 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
      }
    } finally {
      _isLoading = false;
      _isPaginating = false;
      notifyListeners();
    }
  }

  /// Mark single notification as seen (with optimistic local update)
  Future<void> seenNotification(int id) async {
    // 1. Optimistic local update
    if (notificationModel?.notification != null) {
      final index =
          notificationModel!.notification!.indexWhere((element) => element.id == id);
      if (index != -1 &&
          notificationModel!.notification![index].notificationSeenStatus == 0) {
        notificationModel!.notification![index].notificationSeenStatus = 1;
        if (notificationModel!.newNotificationItem != null &&
            notificationModel!.newNotificationItem! > 0) {
          notificationModel!.newNotificationItem =
              notificationModel!.newNotificationItem! - 1;
        }
        notifyListeners();
      }
    }

    // 2. Network call
    try {
      ResponseModel responseModel =
          await notificationServiceInterface.seenNotification(id);
      if (responseModel.isSuccess) {
        // Kept in sync
      }
    } catch (_) {}
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final list = notificationModel?.notification ?? [];
    final unreadItems = list.where((item) => (item.notificationSeenStatus ?? 0) == 0).toList();

    if (unreadItems.isEmpty) return;

    // Optimistic local update
    for (final item in unreadItems) {
      item.notificationSeenStatus = 1;
    }
    notificationModel?.newNotificationItem = 0;
    notifyListeners();

    // Fire network updates in background
    for (final item in unreadItems) {
      if (item.id != null) {
        try {
          await notificationServiceInterface.seenNotification(item.id!);
        } catch (_) {}
      }
    }
  }

  /// Dismiss / remove notification locally
  void removeNotificationLocally(int id) {
    if (notificationModel?.notification != null) {
      final index =
          notificationModel!.notification!.indexWhere((element) => element.id == id);
      if (index != -1) {
        final wasUnread =
            notificationModel!.notification![index].notificationSeenStatus == 0;
        notificationModel!.notification!.removeAt(index);
        if (wasUnread &&
            notificationModel!.newNotificationItem != null &&
            notificationModel!.newNotificationItem! > 0) {
          notificationModel!.newNotificationItem =
              notificationModel!.newNotificationItem! - 1;
        }
        notifyListeners();
      }
    }
  }
}