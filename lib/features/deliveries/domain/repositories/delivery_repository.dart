import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/repositories/delivery_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class DeliveryRepository implements DeliveryRepositoryInterface {
  final ApiClient apiClient;
  DeliveryRepository({required this.apiClient});

  @override
  Future<Response> list({
    int offset = 0,
    int limit = 20,
    String? status,
    int? apiProductId,
    DateTime? from,
    DateTime? to,
  }) {
    final query = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (status != null) 'status': status,
      if (apiProductId != null) 'api_product_id': apiProductId,
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
    };
    return apiClient.getData(
      AppConstants.deliveriesUri,
      query: query,
      handleError: false,
      // Polled endpoint — fail fast so ticks don't stack.
      timeoutSeconds: 8,
    );
  }

  @override
  Future<Response> show(int id) => apiClient.getData(
        '${AppConstants.deliveriesUri}/$id',
        handleError: false,
        timeoutSeconds: 8,
      );

  @override
  Future<Response> requestReassignment(
      int orderId, String reason, String? notes) {
    return apiClient.postData(
      '${AppConstants.orderReassignmentUri}/$orderId/reassign-request',
      {'reason': reason, if (notes != null && notes.isNotEmpty) 'notes': notes},
      handleError: false,
    );
  }
}
