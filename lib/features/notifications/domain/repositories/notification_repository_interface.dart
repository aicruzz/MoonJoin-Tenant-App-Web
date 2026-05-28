import 'package:get/get.dart';

abstract class NotificationRepositoryInterface {
  /// `GET /api/v1/merchant/notifications?offset=&limit=&unread_only=`
  Future<Response> list({
    int offset = 0,
    int limit = 20,
    bool unreadOnly = false,
  });

  /// `POST /api/v1/merchant/notifications/{id}/read`
  Future<Response> markRead(int id);

  /// `POST /api/v1/merchant/notifications/read-all`
  Future<Response> markAllRead();
}
