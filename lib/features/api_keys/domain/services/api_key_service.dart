import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/models/api_key_model.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/repositories/api_key_repository_interface.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/services/api_key_service_interface.dart';

class ApiKeyService implements ApiKeyServiceInterface {
  final ApiKeyRepositoryInterface apiKeyRepo;
  ApiKeyService({required this.apiKeyRepo});

  @override
  Future<ResponseModel> list(int productId) async {
    final response = await apiKeyRepo.list(productId);
    if (!_ok(response)) return _fail(response, 'Could not load API keys');

    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => ApiKeyModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <ApiKeyModel>[];
      return ResponseModel(true, 'ok', ApiKeyListPayload(items));
    }
    return ResponseModel(false, 'Unexpected API keys response');
  }

  @override
  Future<ResponseModel> mint(int productId) async {
    final response = await apiKeyRepo.mint(productId);
    return _reveal(response, 'Could not issue API key');
  }

  @override
  Future<ResponseModel> rotate(int productId) async {
    final response = await apiKeyRepo.rotate(productId);
    return _reveal(response, 'Could not rotate API key');
  }

  @override
  Future<ResponseModel> revoke(int productId, int credentialId) async {
    final response = await apiKeyRepo.revoke(productId, credentialId);
    return _single(response, 'Could not revoke API key');
  }

  @override
  Future<ResponseModel> acknowledgeReveal(
      int productId, int credentialId) async {
    final response = await apiKeyRepo.acknowledgeReveal(productId, credentialId);
    if (response.statusCode == 410) {
      return ResponseModel(false,
          'This key has already been revealed. Rotate to receive a new one.');
    }
    if (!_ok(response)) return _fail(response, 'Could not acknowledge reveal');
    final body = response.body;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic> && data['credential'] is Map) {
        final cred =
            ApiKeyModel.fromJson(Map<String, dynamic>.from(data['credential']));
        return ResponseModel(true, 'ok', ApiKeyPayload(cred));
      }
    }
    return ResponseModel(true, 'ok', null);
  }

  ResponseModel _single(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(true, 'ok',
          ApiKeyPayload(ApiKeyModel.fromJson(data)));
    }
    return ResponseModel(false, 'Unexpected response');
  }

  ResponseModel _reveal(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(true, 'ok',
          ApiKeyRevealPayload(ApiKeyRevealModel.fromJson(data)));
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
