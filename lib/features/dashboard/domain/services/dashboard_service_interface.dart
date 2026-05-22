import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/models/dashboard_summary_model.dart';

abstract class DashboardServiceInterface {
  /// Returns a parsed summary or an error message. Range values accepted by
  /// the Phase A AnalyticsController: `today | 24h | 7d | 30d | 90d` (or
  /// explicit `from`/`to` extension via the repository later).
  Future<ResponseModel> getSummary(String range);
}

class DashboardSummaryPayload {
  final DashboardSummaryModel summary;
  const DashboardSummaryPayload(this.summary);
}
