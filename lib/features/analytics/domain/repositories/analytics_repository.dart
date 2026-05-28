import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/analytics/domain/repositories/analytics_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class AnalyticsRepository implements AnalyticsRepositoryInterface {
  final ApiClient apiClient;
  AnalyticsRepository({required this.apiClient});

  @override
  Future<Response> orders(String range) => apiClient.getData(
        AppConstants.analyticsOrdersUri,
        query: {'range': range},
        handleError: false,
        timeoutSeconds: 12,
      );

  @override
  Future<Response> successRate(String range) => apiClient.getData(
        AppConstants.analyticsSuccessRateUri,
        query: {'range': range},
        handleError: false,
        timeoutSeconds: 8,
      );

  @override
  Future<Response> webhooks(String range) => apiClient.getData(
        AppConstants.analyticsWebhooksUri,
        query: {'range': range},
        handleError: false,
        timeoutSeconds: 12,
      );
}
