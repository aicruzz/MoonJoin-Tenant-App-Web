import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/analytics/domain/models/analytics_models.dart';
import 'package:moonjoin_cloud/features/analytics/domain/repositories/analytics_repository_interface.dart';
import 'package:moonjoin_cloud/features/analytics/domain/services/analytics_service_interface.dart';

class AnalyticsService implements AnalyticsServiceInterface {
  final AnalyticsRepositoryInterface analyticsRepo;
  AnalyticsService({required this.analyticsRepo});

  @override
  Future<ResponseModel> orders(String range) async {
    final response = await analyticsRepo.orders(range);
    if (!_ok(response)) return _fail(response, 'Could not load orders series');
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        OrdersSeriesPayload(AnalyticsOrdersSeries.fromJson(data)),
      );
    }
    return ResponseModel(false, 'Unexpected orders series response');
  }

  @override
  Future<ResponseModel> successRate(String range) async {
    final response = await analyticsRepo.successRate(range);
    if (!_ok(response)) return _fail(response, 'Could not load success rate');
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        SuccessRatePayload(AnalyticsSuccessRate.fromJson(data)),
      );
    }
    return ResponseModel(false, 'Unexpected success rate response');
  }

  @override
  Future<ResponseModel> webhooks(String range) async {
    final response = await analyticsRepo.webhooks(range);
    if (!_ok(response)) return _fail(response, 'Could not load webhook stats');
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        WebhookSeriesPayload(AnalyticsWebhookSeries.fromJson(data)),
      );
    }
    return ResponseModel(false, 'Unexpected webhook series response');
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
}
