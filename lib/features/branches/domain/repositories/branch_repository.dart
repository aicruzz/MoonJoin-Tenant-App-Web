import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/branch_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class BranchRepository implements BranchRepositoryInterface {
  final ApiClient apiClient;
  BranchRepository({required this.apiClient});

  @override
  Future<Response> list({int offset = 0, int limit = 20}) => apiClient.getData(
        AppConstants.branchesUri,
        query: {'offset': offset, 'limit': limit},
        handleError: false,
      );

  @override
  Future<Response> show(int id) =>
      apiClient.getData('${AppConstants.branchesUri}/$id', handleError: false);

  @override
  Future<Response> create(Map<String, dynamic> body) => apiClient.postData(
        AppConstants.branchesUri,
        body,
        handleError: false,
      );

  @override
  Future<Response> update(int id, Map<String, dynamic> body) =>
      apiClient.putData(
        '${AppConstants.branchesUri}/$id',
        body,
        handleError: false,
      );

  @override
  Future<Response> disable(int id) =>
      apiClient.deleteData('${AppConstants.branchesUri}/$id', handleError: false);
}
