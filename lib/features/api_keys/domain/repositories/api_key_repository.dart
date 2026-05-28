import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/repositories/api_key_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class ApiKeyRepository implements ApiKeyRepositoryInterface {
  final ApiClient apiClient;
  ApiKeyRepository({required this.apiClient});

  String _base(int productId) =>
      '${AppConstants.apiProductsUri}/$productId/api-keys';

  @override
  Future<Response> list(int productId) =>
      apiClient.getData(_base(productId), handleError: false);

  @override
  Future<Response> mint(int productId) => apiClient
      .postData(_base(productId), const <String, dynamic>{}, handleError: false);

  @override
  Future<Response> rotate(int productId) => apiClient.postData(
      '${_base(productId)}/rotate', const <String, dynamic>{},
      handleError: false);

  @override
  Future<Response> revoke(int productId, int credentialId) =>
      apiClient.postData(
          '${_base(productId)}/$credentialId/revoke', const <String, dynamic>{},
          handleError: false);

  @override
  Future<Response> acknowledgeReveal(int productId, int credentialId) =>
      apiClient.postData(
          '${_base(productId)}/$credentialId/reveal', const <String, dynamic>{},
          handleError: false);
}
