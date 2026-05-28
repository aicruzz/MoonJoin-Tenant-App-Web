import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/disputes/domain/models/dispute_model.dart';

abstract class DisputeServiceInterface {
  Future<ResponseModel> list({int offset = 0, int limit = 20, String? status});
  Future<ResponseModel> show(int id);
  Future<ResponseModel> create({
    required int orderId,
    required String reason,
    String? description,
  });
}

class DisputeListPayload {
  final List<DisputeModel> items;
  final PageMeta meta;
  const DisputeListPayload({required this.items, required this.meta});
}

class DisputePayload {
  final DisputeModel dispute;
  const DisputePayload(this.dispute);
}
