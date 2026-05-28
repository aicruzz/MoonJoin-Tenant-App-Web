import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/notifications/domain/models/notification_model.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/notification_repository_interface.dart';
import 'package:moonjoin_cloud/features/notifications/domain/services/notification_service_interface.dart';

class NotificationService implements NotificationServiceInterface {
  final NotificationRepositoryInterface notificationRepo;
  NotificationService({required this.notificationRepo});

  @override
  Future<ResponseModel> list({
    int offset = 0,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    final response = await notificationRepo.list(
      offset: offset,
      limit: limit,
      unreadOnly: unreadOnly,
    );
    if (!_ok(response)) return _fail(response, 'Could not load notifications');

    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final unread = body['meta'] is Map<String, dynamic>
          ? _toInt(Map<String, dynamic>.from(body['meta'] as Map)['unread'])
          : 0;
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  NotificationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <NotificationModel>[];
      return ResponseModel(
        true,
        'ok',
        NotificationListPayload(items: items, meta: meta, unread: unread),
      );
    }
    return ResponseModel(false, 'Unexpected notifications response');
  }

  @override
  Future<ResponseModel> markRead(int id) async {
    final response = await notificationRepo.markRead(id);
    if (!_ok(response)) return _fail(response, 'Could not mark notification read');
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        NotificationPayload(NotificationModel.fromJson(data)),
      );
    }
    return ResponseModel(true, 'ok', null);
  }

  @override
  Future<ResponseModel> markAllRead() async {
    final response = await notificationRepo.markAllRead();
    if (!_ok(response)) return _fail(response, 'Could not mark all read');
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        MarkAllReadPayload(_toInt(data['updated'])),
      );
    }
    return ResponseModel(true, 'ok', null);
  }

  bool _ok(Response response) => response.statusCode == 200;

  dynamic _data(Response response) {
    final body = response.body;
    if (body is Map<String, dynamic>) return body['data'] ?? body;
    if (body is Map) return Map<String, dynamic>.from(body)['data'];
    return null;
  }

  ResponseModel _fail(Response response, String fallback) {
    String message = response.statusText ?? fallback;
    final body = response.body;
    if (body is Map) {
      if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
        final first = (body['errors'] as List).first;
        if (first is Map && first['message'] != null) {
          message = first['message'].toString();
        }
      } else if (body['message'] != null) {
        message = body['message'].toString();
      }
    }
    return ResponseModel(false, message);
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
