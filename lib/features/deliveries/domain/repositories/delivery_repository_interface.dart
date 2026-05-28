import 'package:get/get.dart';

abstract class DeliveryRepositoryInterface {
  /// `GET /api/v1/merchant/deliveries?offset=&limit=&status=&api_product_id=&from=&to=`
  Future<Response> list({
    int offset = 0,
    int limit = 20,
    String? status,
    int? apiProductId,
    DateTime? from,
    DateTime? to,
  });

  /// `GET /api/v1/merchant/deliveries/{id}`
  Future<Response> show(int id);

  /// `POST /api/v1/merchant/orders/{id}/reassign-request`
  /// body: `{reason, notes?}` — server enforces idempotency.
  Future<Response> requestReassignment(
      int orderId, String reason, String? notes);
}
