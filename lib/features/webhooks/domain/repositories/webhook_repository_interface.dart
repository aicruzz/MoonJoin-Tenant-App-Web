import 'package:get/get.dart';

abstract class WebhookRepositoryInterface {
  /// `GET /api-products/{productId}/webhook-config`
  Future<Response> show(int productId);

  /// `PUT /api-products/{productId}/webhook-config`
  /// body: `{webhook_url, rotate_secret?: bool}`
  Future<Response> update(int productId, Map<String, dynamic> body);

  /// `POST /api-products/{productId}/webhooks/test` (202)
  Future<Response> test(int productId);

  /// `GET /api-products/{productId}/webhook-deliveries?offset=&limit=&status=&event_type=`
  Future<Response> deliveries(
    int productId, {
    int offset = 0,
    int limit = 20,
    String? status,
    String? eventType,
  });

  /// `POST /api-products/{productId}/webhook-deliveries/{deliveryId}/retry` (202)
  Future<Response> retry(int productId, int deliveryId);
}
