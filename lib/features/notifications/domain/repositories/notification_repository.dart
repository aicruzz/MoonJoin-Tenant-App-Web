import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/notification_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient apiClient;
  NotificationRepository({required this.apiClient});

  @override
  Future<Response> list({
    int offset = 0,
    int limit = 20,
    bool unreadOnly = false,
  }) {
    return apiClient.getData(
      AppConstants.notificationsUri,
      query: {
        'offset': offset,
        'limit': limit,
        if (unreadOnly) 'unread_only': true,
      },
      handleError: false,
      timeoutSeconds: 8,
    );
  }

  @override
  Future<Response> markRead(int id) => apiClient.postData(
        '${AppConstants.notificationsUri}/$id/read',
        const <String, dynamic>{},
        handleError: false,
      );

  @override
  Future<Response> markAllRead() => apiClient.postData(
        '${AppConstants.notificationsUri}/read-all',
        const <String, dynamic>{},
        handleError: false,
      );
}
