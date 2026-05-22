import 'package:get/get.dart';

abstract class DashboardRepositoryInterface {
  /// Phase A: `GET /api/v1/merchant/analytics/summary?range={range}`.
  Future<Response> fetchSummary(String range);
}
