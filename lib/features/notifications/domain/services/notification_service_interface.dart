import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/notifications/domain/models/notification_model.dart';

abstract class NotificationServiceInterface {
  Future<ResponseModel> list({
    int offset = 0,
    int limit = 20,
    bool unreadOnly = false,
  });
  Future<ResponseModel> markRead(int id);
  Future<ResponseModel> markAllRead();
}

class NotificationListPayload {
  final List<NotificationModel> items;
  final PageMeta meta;
  final int unread;
  const NotificationListPayload({
    required this.items,
    required this.meta,
    required this.unread,
  });
}

class NotificationPayload {
  final NotificationModel notification;
  const NotificationPayload(this.notification);
}

class MarkAllReadPayload {
  final int updated;
  const MarkAllReadPayload(this.updated);
}
