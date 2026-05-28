import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/analytics/domain/models/analytics_models.dart';

abstract class AnalyticsServiceInterface {
  Future<ResponseModel> orders(String range);
  Future<ResponseModel> successRate(String range);
  Future<ResponseModel> webhooks(String range);
}

class OrdersSeriesPayload {
  final AnalyticsOrdersSeries series;
  const OrdersSeriesPayload(this.series);
}

class SuccessRatePayload {
  final AnalyticsSuccessRate summary;
  const SuccessRatePayload(this.summary);
}

class WebhookSeriesPayload {
  final AnalyticsWebhookSeries series;
  const WebhookSeriesPayload(this.series);
}
