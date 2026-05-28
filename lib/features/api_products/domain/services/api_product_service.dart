import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/api_products/domain/models/api_product_model.dart';
import 'package:moonjoin_cloud/features/api_products/domain/repositories/api_product_repository_interface.dart';
import 'package:moonjoin_cloud/features/api_products/domain/services/api_product_service_interface.dart';

class ApiProductService implements ApiProductServiceInterface {
  final ApiProductRepositoryInterface apiProductRepo;
  ApiProductService({required this.apiProductRepo});

  @override
  Future<ResponseModel> list({
    int offset = 0,
    int limit = 20,
    String? status,
  }) async {
    final response = await apiProductRepo.list(
        offset: offset, limit: limit, status: status);
    if (!_ok(response)) return _fail(response, 'Could not load API products');

    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  ApiProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <ApiProductModel>[];
      return ResponseModel(
          true, 'ok', ApiProductsPayload(items: items, meta: meta));
    }
    return ResponseModel(false, 'Unexpected API products response');
  }

  @override
  Future<ResponseModel> show(int id) async {
    final response = await apiProductRepo.show(id);
    return _single(response, 'Could not load API product');
  }

  @override
  Future<ResponseModel> create({
    required String name,
    required String productType,
    List<String> supportedCategories = const [],
    List<String> modules = const [],
    String? webhookUrl,
    int? rateLimitPerMinute,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'product_type': productType,
      if (supportedCategories.isNotEmpty)
        'supported_categories': supportedCategories,
      if (modules.isNotEmpty) 'modules': modules,
      if (webhookUrl != null && webhookUrl.isNotEmpty)
        'webhook_url': webhookUrl,
      if (rateLimitPerMinute != null)
        'rate_limit_per_minute': rateLimitPerMinute,
    };
    final response = await apiProductRepo.create(body);
    return _single(response, 'Could not create API product');
  }

  @override
  Future<ResponseModel> update(
    int id, {
    String? name,
    String? productType,
    List<String>? supportedCategories,
    List<String>? modules,
    String? webhookUrl,
    int? rateLimitPerMinute,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (productType != null) 'product_type': productType,
      if (supportedCategories != null)
        'supported_categories': supportedCategories,
      if (modules != null) 'modules': modules,
      if (webhookUrl != null) 'webhook_url': webhookUrl,
      if (rateLimitPerMinute != null)
        'rate_limit_per_minute': rateLimitPerMinute,
    };
    final response = await apiProductRepo.update(id, body);
    return _single(response, 'Could not update API product');
  }

  @override
  Future<ResponseModel> submit(int id) async {
    final response = await apiProductRepo.submit(id);
    return _single(response, 'Could not submit API product');
  }

  ResponseModel _single(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(true, 'ok',
          ApiProductPayload(ApiProductModel.fromJson(data)));
    }
    return ResponseModel(false, 'Unexpected response');
  }

  bool _ok(Response response) =>
      response.statusCode == 200 || response.statusCode == 201;

  dynamic _data(Response response) {
    final body = response.body;
    if (body is Map<String, dynamic>) return body['data'] ?? body;
    if (body is Map) return Map<String, dynamic>.from(body)['data'];
    return null;
  }

  ResponseModel _fail(Response response, String fallback) {
    String message = response.statusText ?? fallback;
    final body = response.body;
    if (body is Map) {
      if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
        final first = (body['errors'] as List).first;
        if (first is Map && first['message'] != null) {
          message = first['message'].toString();
        }
      } else if (body['message'] != null) {
        message = body['message'].toString();
      }
    }
    return ResponseModel(false, message);
  }
}
