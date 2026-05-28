import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/models/api_key_model.dart';

abstract class ApiKeyServiceInterface {
  Future<ResponseModel> list(int productId);
  Future<ResponseModel> mint(int productId);
  Future<ResponseModel> rotate(int productId);
  Future<ResponseModel> revoke(int productId, int credentialId);
  Future<ResponseModel> acknowledgeReveal(int productId, int credentialId);
}

class ApiKeyListPayload {
  final List<ApiKeyModel> items;
  const ApiKeyListPayload(this.items);
}

class ApiKeyRevealPayload {
  final ApiKeyRevealModel reveal;
  const ApiKeyRevealPayload(this.reveal);
}

class ApiKeyPayload {
  final ApiKeyModel credential;
  const ApiKeyPayload(this.credential);
}
