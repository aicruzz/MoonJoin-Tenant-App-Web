import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/models/webhook_config_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/models/webhook_delivery_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/repositories/webhook_repository_interface.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/services/webhook_service_interface.dart';

class WebhookService implements WebhookServiceInterface {
  final WebhookRepositoryInterface webhookRepo;
  WebhookService({required this.webhookRepo});

  @override
  Future<ResponseModel> getConfig(int productId) async {
    final response = await webhookRepo.show(productId);
    return _config(response, 'Could not load webhook config');
  }

  @override
  Future<ResponseModel> updateConfig(
    int productId, {
    required String webhookUrl,
    bool rotateSecret = false,
  }) async {
    final response = await webhookRepo.update(productId, {
      'webhook_url': webhookUrl,
      if (rotateSecret) 'rotate_secret': true,
    });
    return _config(response, 'Could not update webhook config');
  }

  @override
  Future<ResponseModel> sendTestPing(int productId) async {
    final response = await webhookRepo.test(productId);
    return _singleDelivery(response, 'Could not send test ping');
  }

  @override
  Future<ResponseModel> getDeliveries(
    int productId, {
    int offset = 0,
    int limit = 20,
    String? status,
    String? eventType,
  }) async {
    final response = await webhookRepo.deliveries(
      productId,
      offset: offset,
      limit: limit,
      status: status,
      eventType: eventType,
    );
    if (!_ok(response)) return _fail(response, 'Could not load webhook deliveries');

    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => WebhookDeliveryModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <WebhookDeliveryModel>[];
      return ResponseModel(
        true,
        'ok',
        WebhookDeliveryListPayload(items: items, meta: meta),
      );
    }
    return ResponseModel(false, 'Unexpected webhook deliveries response');
  }

  @override
  Future<ResponseModel> retry(int productId, int deliveryId) async {
    final response = await webhookRepo.retry(productId, deliveryId);
    return _singleDelivery(response, 'Could not retry webhook delivery');
  }

  ResponseModel _config(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        WebhookConfigPayload(WebhookConfigModel.fromJson(data)),
      );
    }
    return ResponseModel(false, 'Unexpected webhook config response');
  }

  ResponseModel _singleDelivery(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      final raw = data['delivery'];
      if (raw is Map<String, dynamic>) {
        return ResponseModel(
          true,
          'ok',
          WebhookDeliveryPayload(WebhookDeliveryModel.fromJson(raw)),
        );
      }
    }
    return ResponseModel(false, 'Unexpected webhook delivery response');
  }

  bool _ok(Response response) =>
      response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202;

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
}
