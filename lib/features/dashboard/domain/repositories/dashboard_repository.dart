import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/repositories/dashboard_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class DashboardRepository implements DashboardRepositoryInterface {
  final ApiClient apiClient;
  DashboardRepository({required this.apiClient});

  @override
  Future<Response> fetchSummary(String range) {
    // Short timeout for the polled call: dashboard polls every 30–60 s, so a
    // slow backend should fail fast rather than queue requests behind one
    // another. The 8s budget aligns with the long-polling guidance in the plan.
    return apiClient.getData(
      AppConstants.analyticsSummaryUri,
      query: {'range': range},
      handleError: false,
      timeoutSeconds: 8,
    );
  }
}
