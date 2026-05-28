import 'package:get/get.dart';

abstract class BranchRepositoryInterface {
  Future<Response> list({int offset = 0, int limit = 20});
  Future<Response> show(int id);
  Future<Response> create(Map<String, dynamic> body);
  Future<Response> update(int id, Map<String, dynamic> body);
  Future<Response> disable(int id);
}
