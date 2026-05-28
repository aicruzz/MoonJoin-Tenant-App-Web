import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/disputes/domain/repositories/dispute_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class DisputeRepository implements DisputeRepositoryInterface {
  final ApiClient apiClient;
  DisputeRepository({required this.apiClient});

  @override
  Future<Response> list({int offset = 0, int limit = 20, String? status}) {
    return apiClient.getData(
      AppConstants.disputesUri,
      query: {
        'offset': offset,
        'limit': limit,
        if (status != null) 'status': status,
      },
      handleError: false,
    );
  }

  @override
  Future<Response> show(int id) =>
      apiClient.getData('${AppConstants.disputesUri}/$id', handleError: false);

  @override
  Future<Response> create({
    required int orderId,
    required String reason,
    String? description,
  }) {
    return apiClient.postData(
      AppConstants.disputesUri,
      {
        'order_id': orderId,
        'reason': reason,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      handleError: false,
    );
  }
}
