import 'package:get/get.dart';

abstract class ApiProductRepositoryInterface {
  /// `GET /api/v1/merchant/api-products?offset=&limit=&status=`
  Future<Response> list({int offset = 0, int limit = 20, String? status});

  /// `GET /api/v1/merchant/api-products/{id}`
  Future<Response> show(int id);

  /// `POST /api/v1/merchant/api-products`
  Future<Response> create(Map<String, dynamic> body);

  /// `PUT /api/v1/merchant/api-products/{id}`
  Future<Response> update(int id, Map<String, dynamic> body);

  /// `POST /api/v1/merchant/api-products/{id}/submit`
  Future<Response> submit(int id);
}
