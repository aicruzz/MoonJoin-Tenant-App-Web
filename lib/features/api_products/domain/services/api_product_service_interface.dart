import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/api_products/domain/models/api_product_model.dart';

abstract class ApiProductServiceInterface {
  Future<ResponseModel> list({int offset = 0, int limit = 20, String? status});
  Future<ResponseModel> show(int id);
  Future<ResponseModel> create({
    required String name,
    required String productType,
    List<String> supportedCategories = const [],
    List<String> modules = const [],
    String? webhookUrl,
    int? rateLimitPerMinute,
  });
  Future<ResponseModel> update(
    int id, {
    String? name,
    String? productType,
    List<String>? supportedCategories,
    List<String>? modules,
    String? webhookUrl,
    int? rateLimitPerMinute,
  });
  Future<ResponseModel> submit(int id);
}

class ApiProductPayload {
  final ApiProductModel product;
  const ApiProductPayload(this.product);
}

class ApiProductsPayload {
  final List<ApiProductModel> items;
  final PageMeta meta;
  const ApiProductsPayload({required this.items, required this.meta});
}
