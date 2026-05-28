import 'package:get/get.dart';

abstract class AnalyticsRepositoryInterface {
  /// `GET /api/v1/merchant/analytics/orders?range=`
  Future<Response> orders(String range);

  /// `GET /api/v1/merchant/analytics/success-rate?range=`
  Future<Response> successRate(String range);

  /// `GET /api/v1/merchant/analytics/webhooks?range=`
  Future<Response> webhooks(String range);
}
