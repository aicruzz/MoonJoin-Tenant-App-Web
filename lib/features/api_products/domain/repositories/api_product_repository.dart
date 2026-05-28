import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/api_products/domain/repositories/api_product_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class ApiProductRepository implements ApiProductRepositoryInterface {
  final ApiClient apiClient;
  ApiProductRepository({required this.apiClient});

  @override
  Future<Response> list({int offset = 0, int limit = 20, String? status}) {
    return apiClient.getData(
      AppConstants.apiProductsUri,
      query: {
        'offset': offset,
        'limit': limit,
        if (status != null) 'status': status,
      },
      handleError: false,
    );
  }

  @override
  Future<Response> show(int id) => apiClient
      .getData('${AppConstants.apiProductsUri}/$id', handleError: false);

  @override
  Future<Response> create(Map<String, dynamic> body) => apiClient.postData(
        AppConstants.apiProductsUri,
        body,
        handleError: false,
      );

  @override
  Future<Response> update(int id, Map<String, dynamic> body) => apiClient.putData(
        '${AppConstants.apiProductsUri}/$id',
        body,
        handleError: false,
      );

  @override
  Future<Response> submit(int id) => apiClient.postData(
        '${AppConstants.apiProductsUri}/$id/submit',
        const <String, dynamic>{},
        handleError: false,
      );
}
