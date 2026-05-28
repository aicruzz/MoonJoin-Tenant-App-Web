import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/analytics/domain/models/analytics_models.dart';
import 'package:moonjoin_cloud/features/analytics/domain/services/analytics_service_interface.dart';

/// Manages the three analytics endpoints (orders / success-rate / webhooks).
/// No polling — heavier payloads; range change + pull-to-refresh only.
class AnalyticsController extends GetxController implements GetxService {
  final AnalyticsServiceInterface analyticsService;
  AnalyticsController({required this.analyticsService});

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _range = '7d';
  String get range => _range;

  AnalyticsOrdersSeries? _orders;
  AnalyticsOrdersSeries? get orders => _orders;

  AnalyticsSuccessRate? _successRate;
  AnalyticsSuccessRate? get successRate => _successRate;

  AnalyticsWebhookSeries? _webhooks;
  AnalyticsWebhookSeries? get webhooks => _webhooks;

  void setRange(String value) {
    if (_range == value) return;
    _range = value;
    update();
    // ignore: discarded_futures
    load();
  }

  Future<void> load() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();

    final results = await Future.wait([
      analyticsService.orders(_range),
      analyticsService.successRate(_range),
      analyticsService.webhooks(_range),
    ]);

    final ordersResult = results[0];
    final successResult = results[1];
    final webhookResult = results[2];

    // Treat orders as the gating call; the others enrich the screen but
    // shouldn't block it on transient failure.
    if (!ordersResult.isSuccess) {
      _errorMessage = ordersResult.message;
      _status = LoadingStatus.error;
      update();
      return;
    }
    _orders = (ordersResult.data as OrdersSeriesPayload).series;

    if (successResult.isSuccess && successResult.data is SuccessRatePayload) {
      _successRate = (successResult.data as SuccessRatePayload).summary;
    }
    if (webhookResult.isSuccess && webhookResult.data is WebhookSeriesPayload) {
      _webhooks = (webhookResult.data as WebhookSeriesPayload).series;
    }

    _status = LoadingStatus.content;
    update();
  }

  @override
  Future<void> refresh() => load();
}
