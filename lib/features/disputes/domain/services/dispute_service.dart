import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/disputes/domain/models/dispute_model.dart';
import 'package:moonjoin_cloud/features/disputes/domain/repositories/dispute_repository_interface.dart';
import 'package:moonjoin_cloud/features/disputes/domain/services/dispute_service_interface.dart';

class DisputeService implements DisputeServiceInterface {
  final DisputeRepositoryInterface disputeRepo;
  DisputeService({required this.disputeRepo});

  @override
  Future<ResponseModel> list({
    int offset = 0,
    int limit = 20,
    String? status,
  }) async {
    final response =
        await disputeRepo.list(offset: offset, limit: limit, status: status);
    if (!_ok(response)) return _fail(response, 'Could not load disputes');
    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => DisputeModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <DisputeModel>[];
      return ResponseModel(
        true,
        'ok',
        DisputeListPayload(items: items, meta: meta),
      );
    }
    return ResponseModel(false, 'Unexpected disputes response');
  }

  @override
  Future<ResponseModel> show(int id) async {
    final response = await disputeRepo.show(id);
    return _single(response, 'Could not load dispute');
  }

  @override
  Future<ResponseModel> create({
    required int orderId,
    required String reason,
    String? description,
  }) async {
    final response = await disputeRepo.create(
      orderId: orderId,
      reason: reason,
      description: description,
    );
    return _single(response, 'Could not open dispute');
  }

  ResponseModel _single(Response response, String fallback) {
    if (!_ok(response)) return _fail(response, fallback);
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
          true, 'ok', DisputePayload(DisputeModel.fromJson(data)));
    }
    return ResponseModel(false, 'Unexpected dispute response');
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
