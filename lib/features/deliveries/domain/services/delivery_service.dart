import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/models/delivery_model.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/repositories/delivery_repository_interface.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/services/delivery_service_interface.dart';

class DeliveryService implements DeliveryServiceInterface {
  final DeliveryRepositoryInterface deliveryRepo;
  DeliveryService({required this.deliveryRepo});

  @override
  Future<ResponseModel> list({
    int offset = 0,
    int limit = 20,
    String? status,
    int? apiProductId,
  }) async {
    final response = await deliveryRepo.list(
      offset: offset,
      limit: limit,
      status: status,
      apiProductId: apiProductId,
    );
    if (!_ok(response)) return _fail(response, 'Could not load deliveries');

    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => DeliveryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const <DeliveryModel>[];
      return ResponseModel(
          true, 'ok', DeliveryListPayload(items: items, meta: meta));
    }
    return ResponseModel(false, 'Unexpected deliveries response');
  }

  @override
  Future<ResponseModel> show(int id) async {
    final response = await deliveryRepo.show(id);
    if (!_ok(response)) return _fail(response, 'Could not load delivery');
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
          true, 'ok', DeliveryPayload(DeliveryModel.fromJson(data)));
    }
    return ResponseModel(false, 'Unexpected delivery response');
  }

  @override
  Future<ResponseModel> requestReassignment(
      int orderId, String reason, String? notes) async {
    final response =
        await deliveryRepo.requestReassignment(orderId, reason, notes);
    if (!_okOrAccepted(response)) {
      return _fail(response, 'Could not request reassignment');
    }
    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
          true, 'ok', ReassignmentRequestPayload.fromJson(data));
    }
    return ResponseModel(true, 'ok', null);
  }

  bool _ok(Response response) => response.statusCode == 200;
  bool _okOrAccepted(Response response) =>
      response.statusCode == 200 || response.statusCode == 202;

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
