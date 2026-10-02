import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/data/api/api_checker.dart';
import 'package:sixvalley_delivery_boy/features/notification/domain/models/notifications_model.dart';
import 'package:sixvalley_delivery_boy/features/notification/domain/services/notification_service_interface.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  NotificationModel? _notificationModel;
  NotificationModel? get notificationModel => _notificationModel;
  List<Notifications>? _notificationList;
  List<Notifications>? get notificationList => _notificationList;

  bool _loadFailed = false;
  bool get loadFailed => _loadFailed;
  Future<void> getNotificationList(int offset, {bool reload = true}) async {
    if (_isLoading) return;
    _isLoading = true;
    _loadFailed = false;
    update();
    try {
      final response =
          await notificationServiceInterface.getNotificationList(offset);
      if (response.statusCode == 200) {
        final model = NotificationModel.fromJson(response.body);
        final items = model.notifications ?? <Notifications>[];
        _notificationList =
            offset == 1 ? items : [...?_notificationList, ...items];
        model.notifications = _notificationList;
        _notificationModel = model;
      } else {
        _loadFailed = true;
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _loadFailed = true;
    } finally {
      _isLoading = false;
      update();
    }
  }

  void saveSeenNotificationId(int id) {
    notificationServiceInterface.saveSeenNotificationCount(id);
  }

  int? getSeenNotificationId() {
    return notificationServiceInterface.getSeenNotificationCount();
  }
}
