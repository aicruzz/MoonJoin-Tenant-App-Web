import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/fcm_token_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class FcmTokenRepository implements FcmTokenRepositoryInterface {
  final ApiClient apiClient;
  FcmTokenRepository({required this.apiClient});

  @override
  Future<Response> register({
    required String token,
    String? platform,
    String? deviceId,
  }) {
    return apiClient.postData(
      AppConstants.fcmTokenUri,
      {
        'token': token,
        if (platform != null) 'platform': platform,
        if (deviceId != null) 'device_id': deviceId,
      },
      handleError: false,
    );
  }

  @override
  Future<Response> unregister(String token) => apiClient.deleteData(
        '${AppConstants.fcmTokenUri}?token=${Uri.encodeQueryComponent(token)}',
        handleError: false,
      );
}
