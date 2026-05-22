import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/repositories/dashboard_repository_interface.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/services/dashboard_service_interface.dart';

class DashboardService implements DashboardServiceInterface {
  final DashboardRepositoryInterface dashboardRepo;
  DashboardService({required this.dashboardRepo});

  @override
  Future<ResponseModel> getSummary(String range) async {
    final response = await dashboardRepo.fetchSummary(range);
    if (response.statusCode == 200 && response.body is Map) {
      final body = Map<String, dynamic>.from(response.body as Map);
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      try {
        final summary = DashboardSummaryModel.fromJson(data);
        return ResponseModel(true, 'ok', DashboardSummaryPayload(summary));
      } catch (e) {
        return ResponseModel(false, 'Could not parse dashboard summary: $e');
      }
    }

    String message = response.statusText ?? 'Could not load dashboard';
    final body = response.body;
    if (body is Map && body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final first = (body['errors'] as List).first;
      if (first is Map && first['message'] != null) {
        message = first['message'].toString();
      }
    } else if (body is Map && body['message'] != null) {
      message = body['message'].toString();
    }
    return ResponseModel(false, message);
  }
}
