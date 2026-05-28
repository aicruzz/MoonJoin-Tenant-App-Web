import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/models/webhook_config_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/models/webhook_delivery_model.dart';

abstract class WebhookServiceInterface {
  Future<ResponseModel> getConfig(int productId);
  Future<ResponseModel> updateConfig(
    int productId, {
    required String webhookUrl,
    bool rotateSecret = false,
  });
  Future<ResponseModel> sendTestPing(int productId);
  Future<ResponseModel> getDeliveries(
    int productId, {
    int offset = 0,
    int limit = 20,
    String? status,
    String? eventType,
  });
  Future<ResponseModel> retry(int productId, int deliveryId);
}

class WebhookConfigPayload {
  final WebhookConfigModel config;
  const WebhookConfigPayload(this.config);
}

class WebhookDeliveryListPayload {
  final List<WebhookDeliveryModel> items;
  final PageMeta meta;
  const WebhookDeliveryListPayload({required this.items, required this.meta});
}

class WebhookDeliveryPayload {
  final WebhookDeliveryModel delivery;
  const WebhookDeliveryPayload(this.delivery);
}
