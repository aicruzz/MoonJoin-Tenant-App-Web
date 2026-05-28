import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/branch_model.dart';

abstract class BranchServiceInterface {
  Future<ResponseModel> list({int offset = 0, int limit = 20});
  Future<ResponseModel> show(int id);
  Future<ResponseModel> create({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
    String? email,
  });
  Future<ResponseModel> update(
    int id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
  });
  Future<ResponseModel> disable(int id);
}

class BranchListPayload {
  final List<BranchModel> items;
  final PageMeta meta;
  const BranchListPayload({required this.items, required this.meta});
}

class BranchPayload {
  final BranchModel branch;
  const BranchPayload(this.branch);
}
