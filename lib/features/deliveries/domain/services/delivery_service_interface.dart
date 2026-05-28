import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/models/delivery_model.dart';

abstract class DeliveryServiceInterface {
  Future<ResponseModel> list({
    int offset = 0,
    int limit = 20,
    String? status,
    int? apiProductId,
  });
  Future<ResponseModel> show(int id);
  Future<ResponseModel> requestReassignment(
      int orderId, String reason, String? notes);
}

class DeliveryListPayload {
  final List<DeliveryModel> items;
  final PageMeta meta;
  const DeliveryListPayload({required this.items, required this.meta});
}

class DeliveryPayload {
  final DeliveryModel delivery;
  const DeliveryPayload(this.delivery);
}

class ReassignmentRequestPayload {
  final int id;
  final int orderId;
  final String reason;
  final String status;
  const ReassignmentRequestPayload({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.status,
  });

  factory ReassignmentRequestPayload.fromJson(Map<String, dynamic> json) {
    return ReassignmentRequestPayload(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
