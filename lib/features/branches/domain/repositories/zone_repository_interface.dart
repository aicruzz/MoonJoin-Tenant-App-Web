import 'package:get/get.dart';

abstract class ZoneRepositoryInterface {
  /// `GET /api/v1/merchant/zones/check?lat=&lng=`
  Future<Response> check(double lat, double lng);
}
