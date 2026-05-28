import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/branch_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/branch_repository_interface.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/branch_service_interface.dart';

class BranchService implements BranchServiceInterface {
  final BranchRepositoryInterface branchRepo;
  BranchService({required this.branchRepo});

  @override
  Future<ResponseModel> list({int offset = 0, int limit = 20}) async {
    final response = await branchRepo.list(offset: offset, limit: limit);
    if (!_ok(response)) return _fail(response, 'Could not load branches');
    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <BranchModel>[];
      return ResponseModel(
          true, 'ok', BranchListPayload(items: items, meta: meta));
    }
    return ResponseModel(false, 'Unexpected branches response');
  }

  @override
  Future<ResponseModel> show(int id) async {
    final response = await branchRepo.show(id);
    return _single(response, 'Could not load branch');
  }

  @override
  Future<ResponseModel> create({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
    String? email,
  }) async {
    final response = await branchRepo.create({
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return _single(response, 'Could not create branch');
  }

  @override
  Future<ResponseModel> update(
    int id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    };
    final response = await branchRepo.update(id, body);
    return _single(response, 'Could not update branch');
  }

  @override
  Future<ResponseModel> disable(int id) async {
    final response = await branchRepo.disable(id);
    if (!_ok(response)) return _fail(response, 'Could not disable branch');
    return ResponseModel(true, 'ok', null);
  }

  ResponseModel _single(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(true, 'ok',
          BranchPayload(BranchModel.fromJson(data)));
    }
    return ResponseModel(false, 'Unexpected branch response');
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
