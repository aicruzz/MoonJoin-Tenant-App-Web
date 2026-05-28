import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/repositories/webhook_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class WebhookRepository implements WebhookRepositoryInterface {
  final ApiClient apiClient;
  WebhookRepository({required this.apiClient});

  String _base(int productId) => '${AppConstants.apiProductsUri}/$productId';

  @override
  Future<Response> show(int productId) => apiClient.getData(
      '${_base(productId)}/webhook-config',
      handleError: false);

  @override
  Future<Response> update(int productId, Map<String, dynamic> body) =>
      apiClient.putData(
        '${_base(productId)}/webhook-config',
        body,
        handleError: false,
      );

  @override
  Future<Response> test(int productId) => apiClient.postData(
        '${_base(productId)}/webhooks/test',
        const <String, dynamic>{},
        handleError: false,
      );

  @override
  Future<Response> deliveries(
    int productId, {
    int offset = 0,
    int limit = 20,
    String? status,
    String? eventType,
  }) {
    final query = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (status != null) 'status': status,
      if (eventType != null) 'event_type': eventType,
    };
    return apiClient.getData(
      '${_base(productId)}/webhook-deliveries',
      query: query,
      handleError: false,
    );
  }

  @override
  Future<Response> retry(int productId, int deliveryId) => apiClient.postData(
        '${_base(productId)}/webhook-deliveries/$deliveryId/retry',
        const <String, dynamic>{},
        handleError: false,
      );
}
