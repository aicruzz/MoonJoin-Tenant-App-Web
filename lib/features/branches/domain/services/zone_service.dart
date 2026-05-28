import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/zone_check_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/zone_repository_interface.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/zone_service_interface.dart';

class ZoneService implements ZoneServiceInterface {
  final ZoneRepositoryInterface zoneRepo;
  ZoneService({required this.zoneRepo});

  @override
  Future<ResponseModel> check(double lat, double lng) async {
    final response = await zoneRepo.check(lat, lng);
    if (response.statusCode != 200) {
      return ResponseModel(false, response.statusText ?? 'Could not check zone');
    }
    final body = response.body;
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body;
      if (data is Map) {
        return ResponseModel(
          true,
          'ok',
          ZoneCheckPayload(
              ZoneCheckModel.fromJson(Map<String, dynamic>.from(data))),
        );
      }
    }
    return ResponseModel(false, 'Unexpected zone check response');
  }
}
