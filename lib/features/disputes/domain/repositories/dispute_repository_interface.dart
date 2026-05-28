import 'package:get/get.dart';

abstract class DisputeRepositoryInterface {
  Future<Response> list({int offset = 0, int limit = 20, String? status});
  Future<Response> show(int id);
  Future<Response> create({
    required int orderId,
    required String reason,
    String? description,
  });
}
